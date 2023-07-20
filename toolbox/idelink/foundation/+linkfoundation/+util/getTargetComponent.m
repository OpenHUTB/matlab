function tgt=getTargetComponent(cs)





    codegen=cs.getComponent(linkfoundation.util.getCodeGenComponentName);
    tgt=codegen.getComponent('Target');

end