local graph = require "./graph"
type Node<T> = graph.Node<T>
local get_scope = graph.get_scope

local function untrack<T>(source: () -> T): T
    local scope = get_scope()
    
    if scope then
        -- sources are only tracked if the node in scope has an effect
        local effect = scope.effect
        scope.effect = false

        local ok, result = xpcall(source, debug.traceback)

        scope.effect = effect :: () -> ()

        if not ok then error(result, 0) end

        return result :: T
    else
        return source()
    end
end

return untrack :: ( <T>(fn: () -> T) -> T ) & ( (fn: () -> ()) -> () )
