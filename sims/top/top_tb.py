from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class Top( VerilogPlaceholder, Component ):
  def construct( s ):
    pass

model = Top()
model.elaborate()

# Apply the Verilog import passes and the default pass group

model.apply( VerilogPlaceholderPass() )
model = VerilogTranslationImportPass()( model )
model.apply( DefaultPassGroup(linetrace=True,textwave=True,vcdwave="imul-v1-adhoc-test") )

model.sim_reset()


model.sim_tick()
model.sim_tick()
model.sim_tick()
model.print_textwave()
