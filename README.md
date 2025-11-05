# [IC-I] Roulette

Реализация "рулетки" через тип для контроллера предметов.

## Пример использования

```json
{
    "Item": "Roulette",
    "Items": [
        {
            "Chance": 91,
            "Message": "Увы, вам ничего не выпало.",
            "Items": {
                "Item": "None"
            }
        },
        {
            "Chance": 5,
            "Message": "Вам выпала АВП.",
            "Items": {
                "Item": "Weapon",
                "Name": "weapon_awp"
            }
        },
        {
            "Chance": 3,
            "Message": "Вам выпал калаш.",
            "Items": {
                "Item": "Weapon",
                "Name": "weapon_ak47"
            }
        },
        {
            "Chance": 1,
            "Message": "Вам выпал дигл.",
            "Items": {
                "Item": "Weapon",
                "Name": "weapon_deagle"
            }
        }
    ]
}
```
