import itemDatabase from "./ItemDatabase.json"
import fluidDatabase from "./FluidDatabase.json"

function getIcon(obj, prefixPath) {
    if (itemUtil.isItem(obj)) {
        const item = itemUtil.getItem(obj)
        if (item && item["maxDurability"] !== 1) {
            return prefixPath + obj["name"].replaceAll("|", "_").replaceAll(":", "/") + "/1.png"
        }
        return prefixPath + obj["name"].replaceAll("|", "_").replaceAll(":", "/") + "/" + obj["damage"] + ".png"
    }
    return prefixPath + "none.png"
}

const itemUtil = {
    isItem: (obj) => {
        return obj && obj["name"] && obj["damage"] !== null
    },
    getItem: (obj) => {
        if (itemUtil.isItem(obj)) {
            let name = obj["name"]
            if (!itemDatabase[name]) {
                name = name.replaceAll("|", "_")
                if (!itemDatabase[name]) return null
            }
            const damage = (obj["damage"] ? obj["damage"] : 0) + ""
            console.log(name, damage)
            return itemDatabase[name][damage]
        }
        return null
    },
    getName: (obj) => {
        let item = itemUtil.getItem(obj);
        let name = item && item.tr ? item.tr : obj.label;
        if (name === "???液滴") {
            name = [obj.label.replaceAll('drop of ', '')] + '液滴'
        }
        return name
    },
    getIcon: (obj) => {
        return getIcon(obj, "img/items/")
    }
}

export default itemUtil