package.path = package.path..';../?.lua;../../lua-typesys/?.lua'
package.path = package.path..';../../lua-typesys/PlantUML/?.lua'

require("TypeSystemHeader")
require("ScriptSystemHeader")
require("TypesysPlantUML")

local toPlantUMLSucceed = typesys.tools.toPlantUML("test.puml")
print("to plantuml: "..tostring(toPlantUMLSucceed).."\n")