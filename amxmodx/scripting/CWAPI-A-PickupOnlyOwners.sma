#include <amxmodx>
#include <reapi>
#include <json>
#include <cwapi>
#include <ParamsController>

enum E_BlockType {
    BlockType_Invalid = -1,

    BlockType_Default,
    BlockType_Drop,
    BlockType_Remove,
    BlockType_CantPickup,
}

new const ABILITY_NAME[] = "PickupOnlyOwners";
new const PARAM_TYPE_NAME[] = "CWAPI-A-POO-BlockType";
new const PARAM_BLOCK_TYPE_NAME[] = "BlockType";
new const PARAM_IMMUNE_FLAGS_NAME[] = "ImmuneFlags";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;

public ParamsController_OnRegisterTypes() {
    ParamsController_RegSimpleType(PARAM_TYPE_NAME, "@OnBlockTypeParamRead");
}

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Pickup Only Owners", "1.1.2", "ArKaNeMaN");
    register_dictionary("CWAPI-A-PickupOnlyOwners.ini");
    ParamsController_Init();

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);

    CWAPI_Abilities_AddParams(iAbility,
        PARAM_BLOCK_TYPE_NAME, PARAM_TYPE_NAME, true,
        PARAM_IMMUNE_FLAGS_NAME, "ShortString", false
    );
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnAddPlayerItem, "@OnAddPlayerItem");
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnPlayerTouchWeaponBox, "@OnPlayerTouchWeaponBox");
}

@OnAddPlayerItem(const T_CustomWeapon:iWeapon, const ItemId, const UserId, const Trie:tAbilityParams) {
    if (get_entvar(ItemId, var_CWAPI_ItemOwner) == UserId) {
        return;
    }

    new sImmuneFlags[32];
    TrieGetString(tAbilityParams, PARAM_IMMUNE_FLAGS_NAME, sImmuneFlags, charsmax(sImmuneFlags));

    if (get_user_flags(UserId) & read_flags(sImmuneFlags)) {
        return;
    }

    new E_BlockType:iBlockType;
    TrieGetCell(tAbilityParams, PARAM_BLOCK_TYPE_NAME, iBlockType);

    new sItemClassname[32];
    get_entvar(ItemId, var_classname, sItemClassname, charsmax(sItemClassname));

    switch (iBlockType) {
        case BlockType_Default: {
            rg_remove_item(UserId, sItemClassname);
            rg_give_item(UserId, sItemClassname);
        }
        case BlockType_Drop, BlockType_CantPickup: {
            rg_drop_item(UserId, sItemClassname);
        }
        case BlockType_Remove: {
            rg_remove_item(UserId, sItemClassname);
        }
    }
    
    client_print(UserId, print_center, "%L", UserId, "CWAPI_A_POO_BLOCK_MESSAGE");
}

new g_iLastTouch[MAX_PLAYERS + 1] = {0, ...};
new const TOUCH_CHECK_INTERVAL = 1;

@OnPlayerTouchWeaponBox(const T_CustomWeapon:iWeapon, const iWeaponBox, const ItemId, const UserId, const Trie:tAbilityParams) {
    if (g_iLastTouch[UserId] + TOUCH_CHECK_INTERVAL > get_systime()) {
        return CWAPI_STOP_MAIN;
    }

    new OwnerId = get_entvar(ItemId, var_CWAPI_ItemOwner);
    if (!OwnerId || OwnerId == UserId) {
        return CWAPI_CONTINUE;
    }

    new E_BlockType:iBlockType;
    TrieGetCell(tAbilityParams, PARAM_BLOCK_TYPE_NAME, iBlockType);

    if (iBlockType != BlockType_CantPickup) {
        return CWAPI_CONTINUE;
    }

    new sImmuneFlags[32];
    TrieGetString(tAbilityParams, PARAM_IMMUNE_FLAGS_NAME, sImmuneFlags, charsmax(sImmuneFlags));

    if (get_user_flags(UserId) & read_flags(sImmuneFlags)) {
        return CWAPI_CONTINUE;
    }
    
    g_iLastTouch[UserId] = get_systime();
    client_print(UserId, print_center, "%L", UserId, "CWAPI_A_POO_BLOCK_MESSAGE");
    return CWAPI_STOP_MAIN;
}

bool:@OnBlockTypeParamRead(const JSON:jValue) {
    new sBlockType[16];
    json_get_string(jValue, sBlockType, charsmax(sBlockType));

    new E_BlockType:iBlockType = StrToBlockType(sBlockType);
    if (iBlockType == BlockType_Invalid) {
        return false;
    }

    return ParamsController_SetCell(iBlockType);
}

E_BlockType:StrToBlockType(const sBlockType[]) {
    if (equali(sBlockType, "Default")) {
        return BlockType_Default;
    } else if (equali(sBlockType, "Drop")) {
        return BlockType_Drop;
    } else if (equali(sBlockType, "Remove")) {
        return BlockType_Remove;
    } else if (equali(sBlockType, "CantPickup")) {
        return BlockType_CantPickup;
    }

    return BlockType_Invalid;
}
