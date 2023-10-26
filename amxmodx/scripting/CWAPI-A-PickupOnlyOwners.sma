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
}

new const ABILITY_NAME[] = "PickupOnlyOwners";
new const PARAM_TYPE_NAME[] = "CWAPI-A-POO-BlockType";

new const PARAM_BLOCK_TYPE_NAME[] = "BlockType";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;

public ParamsController_OnRegisterTypes() {
    ParamsController_RegSimpleType(PARAM_TYPE_NAME, "@OnBlockTypeParamRead");
}

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Pickup Only Owners", "1.0.0", "ArKaNeMaN");
    register_dictionary("CWAPI-A-PickupOnlyOwners");

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);

    CWAPI_Abilities_AddParams(iAbility,
        PARAM_BLOCK_TYPE_NAME, PARAM_TYPE_NAME, true
    );
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnAddPlayerItem, "@OnAddPlayerItem");
}

@OnAddPlayerItem(const T_CustomWeapon:iWeapon, const ItemId, const UserId, const Trie:tAbilityParams) {
    if (get_entvar(ItemId, var_CWAPI_ItemOwner) == UserId) {
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
        case BlockType_Drop: {
            rg_drop_item(UserId, sItemClassname);
        }
        case BlockType_Remove: {
            rg_remove_item(UserId, sItemClassname);
        }
    }
    
    client_print(UserId, print_center, "%L", LANG_PLAYER, "CWAPI_A_POO_BLOCK_MESSAGE");
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
    }

    return BlockType_Invalid;
}
