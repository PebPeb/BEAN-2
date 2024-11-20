
from vcd.reader import tokenize, TokenKind
import time


def main():
    buildModuleTree()
    

def buildModuleTree():
    # Define the file path to your VCD file
    vcd_file_path = "BEAN_2_tb.vcd"

    root = None
    currentModule = None

    # Open the VCD file in binary mode ('rb') and parse it
    with open(vcd_file_path, 'rb') as f:  # Use 'rb' to open in binary mode
        for token in tokenize(f):
            if token.kind == TokenKind.SCOPE:
                if not root:
                    root = Module(token.data.ident)
                    currentModule = root
                else:
                    currentModule = currentModule.addSubmodule(Module(token.data.ident))
            elif token.kind == TokenKind.UPSCOPE:
                if currentModule == root:
                    pass
                else:
                    currentModule = currentModule.getParentModule()
            elif token.kind == TokenKind.VAR:
                currentModule.addSignal(Wire(token.data.reference, token.data.size, token.data.id_code))
            elif token.kind == TokenKind.ENDDEFINITIONS:
                break
            
    
    print(root.tree_str())


            
# Module Object            
class Module():
    def __init__(self, name, parentModule=None, signals=[], submodules=[]):
        self.name = name        
        
        if (parentModule != None):
            if (isinstance(parentModule, Module)):
                self.parentModule = parentModule
            else:
                raise TypeError("The parentModule must be an instance of the Module class.")  
        else:
            self.parentModule = parentModule
            
        validType = True
        for x in signals:
            if not isinstance(x, Wire):
                validType = False
                raise TypeError("The signals must be a list of instances of the Wire class.")  
        if validType:
            self.signals = signals[:]           # Copy List not pointer
            
            
        validType = True
        for x in submodules:
            if not isinstance(x, Module):
                validType = False    
                raise TypeError("The submodules must be a list of instances of the Module class.")  
        if validType:
            self.submodules = submodules[:]
        
    def setParentModule(self, parentModule):
        self.parentModule = parentModule
        
    def getParentModule(self):
        return self.parentModule
        
    def addSignal(self, signal):
        if isinstance(signal, Wire):
            self.signals.append(signal)
        else:
            raise TypeError("The signal must be an instance of the Wire class.")
    
    # Set submodules parent module to current module
    def addSubmodule(self, submodule):    
        if isinstance(submodule, Module):
            submodule.setParentModule(self)                     
            self.submodules.append(submodule)
        else:
            raise TypeError("The submodule must be an instance of the Module class.")  
        return submodule

    def module_tree_str(self):
        return self.__str_module_tree()
    def tree_str(self):
        return self.__str_module_tree(wires=True)
    def wires_str(self, indent=""):
        return self.__str_wires(indent)
    
    def __repr__(self):     
        return self.__str_module_tree()
    
    def __str_wires(self, indent=""):
        returnStr = ""
        for x in self.signals:
            returnStr += indent + str(x) + "\n"
        return returnStr
    
    def __str_module_tree(self, wires=False):
        vertical_line = '\u2502'
        space = ' '
        
        returnStr = ""
        returnStr += self.name + "\n"
        if self.submodules:
            prevSubmodule = None
            submodule = self.submodules[0]
            depth = 1
            
            while(submodule.getParentModule() != self.getParentModule()):                
                numberSubmodules = len(submodule.getParentModule().submodules)
                index = submodule.getParentModule().submodules.index(submodule)
                
                if not (prevSubmodule == submodule):
                    if (numberSubmodules == (index + 1)):
                        returnStr += f"{vertical_line: <5}"*(depth-1) + "\u2514\u2500\u2500" + " " + submodule.name + "\n"
                        if wires:
                            returnStr += submodule.wires_str(f"{vertical_line: <5}"*(depth-1) + str(f"{space: <5}" + "\u251C\u2500\u2500 "))
                    else:
                        returnStr += f"{vertical_line: <5}"*(depth-1) + "\u251C\u2500\u2500" + " " + submodule.name + "\n"
                        if wires:
                            returnStr += submodule.wires_str(str(f"{vertical_line: <5}"*(depth) + "\u251C\u2500\u2500 "))
                    if wires:    
                        returnStr += "\n"
                             
                if len(submodule.submodules) == 0 or (prevSubmodule == submodule):    
                    if ((index + 1) == numberSubmodules):
                        submodule = submodule.getParentModule()
                        prevSubmodule = submodule
                        depth -= 1
                    else:
                        submodule = submodule.getParentModule().submodules[index + 1]             
                else:
                    submodule = submodule.submodules[0]
                    depth += 1
                    
        return returnStr
    
 
# Wire Object
class Wire():
    def __init__(self, name, width, identifier):
        self.name = name
        self.width = width
        self.identifier = identifier
        
        
    def __repr__(self):
        returnStr = ""
        returnStr += f"{f'{self.name}':<15}" 
        if self.width > 1:
            returnStr += f"{f'wire [{self.width - 1}:0]':<15}"
        else:
            returnStr += f"{f'wire':<15}"
        return returnStr 


if __name__ == "__main__":
    main()