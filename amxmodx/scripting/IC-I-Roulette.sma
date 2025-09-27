#include <amxmodx>
#include <json>
#include <ItemsController>
#include <ParamsController>

new const ITEM_TYPE_NAME[] = "Roulette";
new const ROULETTE_ITEMS_PARAM_TYPE_NAME[] = "IC-I-Roulette-Items";

enum _:S_RouletteItem {
    RouletteItem_Chance,
    Array:RouletteItem_Items,
    RouletteItem_Message[PARAM_CHAT_MESSAGE_MAX_LEN],
}

public stock const PluginName[] = "[IC-I] Roulette";
public stock const PluginVersion[] = "1.0.0";
public stock const PluginAuthor[] = "ArKaNeMaN";

public IC_ItemType_OnInited() {
    register_plugin(PluginName, PluginVersion, PluginAuthor);

    new T_IC_ItemType:type = IC_ItemType_SimpleRegister(
        .name = ITEM_TYPE_NAME,
        .onGive = "@OnGive"
    );
    IC_ItemType_AddParams(type,
        "Items", ROULETTE_ITEMS_PARAM_TYPE_NAME, true
    );
}

public ParamsController_OnRegisterTypes() {
    ParamsController_RegSimpleType(ROULETTE_ITEMS_PARAM_TYPE_NAME, "@OnItemsRead");
}

bool:@OnItemsRead(const JSON:valueJson) {
    if (!json_is_array(valueJson)) {
        PCJson_LogForFile(valueJson, "WARNING", "Roulette items must be an array.");
        return false;
    }

    new Array:items = ArrayCreate(S_RouletteItem, 1);
    new item[S_RouletteItem];

    for (new i = 0, ii = json_array_get_count(valueJson); i < ii; ++i) {
        new JSON:itemJson = json_array_get_value(valueJson, i);
        if (!json_is_object(itemJson)) {
            PCJson_LogForFile(valueJson, "WARNING", "Roulette item #%d must be an object. Item skipped.", i);
            json_free(itemJson);
            continue;
        }

        ReadItem(itemJson, item);
        ArrayPushArray(items, item);

        json_free(itemJson);
    }

    if (ArraySize(items) == 0) {
        PCJson_LogForFile(valueJson, "WARNING", "Roulette items array is empty or all items are invalid.");
        ArrayDestroy(items);
        return false;
    }

    return ParamsController_SetCell(items);
}

ReadItem(const JSON:valueJson, item[S_RouletteItem]) {
    PCSingle_ObjChatMessage(valueJson, "Message", item[RouletteItem_Message], charsmax(item[RouletteItem_Message]));
    item[RouletteItem_Chance] = PCSingle_ObjInt(valueJson, "Chance", 1);
    item[RouletteItem_Items] = PCSingle_ObjIcItems(valueJson, "Items");

    return true;
}

@OnGive(const playerIndex, const Trie:p) {
    new tickets = 0;
    new Array:items = PCGet_Cell(p, "Items");

    for (new i = 0, ii = ArraySize(items); i < ii; ++i) {
        tickets += ArrayGetCell(items, i, RouletteItem_Chance);
    }

    new ticket = random_num(1, tickets);
    
    for (new i = 0, ii = ArraySize(items); i < ii; ++i) {
        new item[S_RouletteItem];
        ArrayGetArray(items, i, item);

        ticket -= item[RouletteItem_Chance];
        if (ticket > 0) {
            continue;
        }

        if (item[RouletteItem_Message][0] != EOS) {
            client_print_color(playerIndex, print_team_default, "%s", item[RouletteItem_Message]);
        }

        if (item[RouletteItem_Items] == Invalid_Array || ArraySize(item[RouletteItem_Items]) == 0) {
            return IC_RET_GIVE_SUCCESS;
        }
        
        return IC_Item_GiveArray(playerIndex, item[RouletteItem_Items]) ? IC_RET_GIVE_SUCCESS : IC_RET_GIVE_FAIL;
    }

    return IC_RET_GIVE_FAIL;
}
