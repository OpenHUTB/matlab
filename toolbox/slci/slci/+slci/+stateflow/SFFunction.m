


classdef SFFunction<slci.stateflow.StateflowFunction

    methods

        function BuildTransitionLists(aObj)
            gfnObj=aObj.getUDDObject;
            transitionObjs=gfnObj.defaultTransitions;
            for idx=1:numel(transitionObjs)
                id=transitionObjs(idx).Id;
                transition=aObj.ParentChart.getTransitionFromId(id);
                assert(~isempty(transition));
                aObj.AddDefaultTransition(transition);
            end
        end

        function aObj=SFFunction(aGraphicalFunctionUDDObj,aParent,addConstraints)
            aObj=aObj@slci.stateflow.StateflowFunction(aGraphicalFunctionUDDObj,aParent,addConstraints);
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameFunction');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameFunctions');

            children=aGraphicalFunctionUDDObj.getChildren();


            aObj.setData(children,'Input');
            aObj.setData(children,'Output');
            aObj.setData(children,'Temporary');
            aObj.setData(children,'Local');
            aObj.setData(children,'Constant');


            aObj.setInplacePairName(children);


            aObj.addConstraint(...
            slci.compatibility.UniqueGraphicalFunctionNameConstraint);


            aObj.addConstraint(...
            slci.compatibility.SupportedNonInlinedGraphicalFunctionConstraint);
        end
    end
end
