local component = require("component")
local me = component.me_controller

ae = {}

local function getSimpleInfo(cpu)
    return {
        cpu = {},
        busy = cpu.busy,
        coprocessors = cpu.coprocessors,
        storage = cpu.storage,
        name = cpu.name
    }
end

local function simpleItemInfo(item)
    if item == nil then return nil end
    return {
        name = item.name,
        label = item.label,
        damage = item.damage,
        size = item.size
    }
end

local function simpleItemsInfo(items)
    if items == nil then return end
    for i, item in pairs(items) do
        items[i] = simpleItemInfo(item)
    end
end

local function removeEmptyItem(items)
    if items == nil then return nil end

    local newOne = {}
    for _, item in pairs(items) do
        if item.size ~= nil and item.size ~= 0 or item.amount ~= nil and item.amount ~= 0 then
            table.insert(newOne, simpleItemInfo(item))
        end
    end
    return newOne
end

local function getDetailInfo(cpu)
    local sub = cpu.cpu
    local result = {
        activeItems = removeEmptyItem(sub.activeItems()),
        finalOutput = sub.finalOutput(),
        active = sub.isActive(),
        busy = sub.isBusy(),
        pendingItems = removeEmptyItem(sub.pendingItems()),
        storedItems = removeEmptyItem(sub.storedItems())
    }
    return result
end

local function getCpuInfoByName(cpuName)
    if not cpuName or cpuName == "" then
        return { message = "CPU 名称为空" }
    end

    local cpus = me.getCpus()
    if not cpus then
        return { message = "未找到 CPU" }
    end

    for _, cpu in pairs(cpus) do
        if cpu.name == cpuName then
            return { message = "success", data = getSimpleInfo(cpu) }
        end
    end

    return { message = "没有找到名称为 " .. cpuName .. " 的 CPU" }
end

function ae.getCpuList(detail)
    -- 获取所有CPU信息
    local cpus = me.getCpus()
    if cpus == nil then return {} end
    local result = {}
    for _, cpu in pairs(cpus) do
        local simple = getSimpleInfo(cpu)
        if detail then simple.cpu = getDetailInfo(cpu) end
        table.insert(result, simple)
    end
    return result
end

function ae.getCpuDetail(cpuName)
    -- 获取指定CPU信息
    local cpus = me.getCpus()
    if cpus == nil then return nil end
    for _, cpu in pairs(cpus) do
        if cpu.name == cpuName then
            local result = getSimpleInfo(cpu)
            result.cpu = getDetailInfo(cpu)
            return result
        end
    end
    return nil
end

function ae.requestItem(name, damage, amount, cpuName)
    -- 请求合成指定的物品
    -- 参数:
    -- name (string): 要合成物品的名称
    -- damage (int): 物品的损坏值
    -- amount (int, 可选): 要合成的物品数量，默认值为1
    -- cpuName (string, 可选): 用于执行任务的CPU名称，若为空则系统自动选择
    if not name or not damage then
        return { message = "物品信息为空" }
    end

    local craftable = me.getCraftables({
        name = name,
        damage = damage
    })[1]
    if not craftable then
        return { message = "没有找到指定的物品" }
    end

    amount = amount or 1


    local result
    if not cpuName or cpuName == "" then
        result = craftable.request(amount, true)
    else
        -- 检查CPU是否存在并且为空闲状态
        local cpuInfo = getCpuInfoByName(cpuName)
        if cpuInfo.message == "success" then
            if cpuInfo.data.busy then
                return { message = "CPU 正忙" }
            else
                result = craftable.request(amount, nil, cpuName)
            end
        else
            return cpuInfo
        end
    end

    if not result then
        return { message = "合成物品失败" }
    end

    local res = {
        item = craftable.getItemStack(),
        failed = result.hasFailed() or false,
        computing = result.isComputing() or false,
        done = { result = false, why = nil },
        canceled = { result = false, why = nil }
    }

    res.done.result, res.done.why = result.isDone()
    res.canceled.result, res.canceled.why = result.isCanceled()

    return { message = "success", data = res }
end

function ae.getAllItems(filter)
    -- 获取所有物品
    local items = me.getItemsInNetwork(filter)
    return removeEmptyItem(items)
end

function ae.getAllCraftables()
    -- 获取所有可合成的物品

    local items = me.getItemsInNetwork()
    if not items then return {} end

    local result = {}
    for _, item in pairs(items) do
        if item.isCraftable then
            table.insert(result, {
                name = item.name,
                label = item.label,
                size = item.size,
                damage = item.damage
            })
        end
    end

    return result
end

function ae.cancelCraftingByCpuName(cpuName)
    -- 根据 CPU 名称取消合成任务
    -- 参数:
    -- cpuName (string): 要取消合成任务的 CPU 名称, 如果为空则不执行任何操作

    if not cpuName or cpuName == "" then
        return { message = "CPU 名称为空，无法取消合成任务" }
    end

    local cpus = me.getCpus()
    if not cpus then
        return { message = "未找到任何 CPU" }
    end

    for _, cpu in pairs(cpus) do
        if cpu.name == cpuName then
            local currentCpu = cpu.cpu
            if currentCpu then
                currentCpu.cancel()
                return { message = "已取消 CPU: " .. cpuName .. " 的合成任务" }
            else
                return { message = "取消合成任务失败，CPU: " .. cpuName }
            end
        end
    end

    return { message = "没有找到名称为 " .. cpuName .. " 的 CPU" }
end
