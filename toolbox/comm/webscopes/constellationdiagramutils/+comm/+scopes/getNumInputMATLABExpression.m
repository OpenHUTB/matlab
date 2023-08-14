function numInputPort=getNumInputMATLABExpression(~,~,clientID,~)
    try
        numInputPort=1;
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;
        blockConfig=get_param(block,'ScopeConfiguration');
        num=get_param(block,'NumInputPorts');
        if str2double(num)==1
            return;
        end
        refConstellationDialog=blockConfig.ReferenceConstellation;
        [refValue,isNumRefChanged]=blockConfig.updateReferenceConstellaltionValues(refConstellationDialog,str2double(num));
        if(isNumRefChanged)
            preserveDirty=Simulink.PreserveDirtyFlag(bdroot(block),'blockDiagram');%#ok
            blockConfig.ReferenceConstellation=refValue;


            pause(0.1)
        end
        numInputPort=str2double(num);
    catch

    end
end