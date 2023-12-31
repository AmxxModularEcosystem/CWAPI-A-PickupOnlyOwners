# [CWAPI-A] Pickup Only Owners

Способность для кастомных оружий Custom Weapons API, позволяющая подбирать их только владельцами.

Название способности: `PickupOnlyOwners`.

## Требования

- Custom Weapons API v0.8

## Параметры

| Название    | Тип    | Обязательный? | Описание                                                                  |
| :---------- | :----- | :------------ | :------------------------------------------------------------------------ |
| `BlockType` | Строка | Да            | Способ блокировки поднятия (см. [таблицу](#доступные-значение-blocktype) ниже) |

### Доступные значение `BlockType`

| Значение  | Описание                                                              |
| :-------- | :-------------------------------------------------------------------- |
| `Default` | При поднятии выдать стандартное оружие, на котором основано кастомное |
| `Drop`    | После поднятия сразу же выкинуть оружие обратно на землю              |
| `Remove`  | Удалить поднятое оружие                                               |

## Пример оружия со способностью

```jsonc
{
    "Reference": "weapon_deagle",
    // ... другие параметры ...
    
    "Abilities": {
        // ... другие способности ...
        "PickupOnlyOwners": {
            "BlockType": "Drop"
        }
    }
}
```
