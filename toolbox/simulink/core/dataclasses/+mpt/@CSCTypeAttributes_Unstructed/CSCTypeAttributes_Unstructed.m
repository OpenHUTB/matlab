classdef CSCTypeAttributes_Unstructed<Simulink.CustomStorageClassAttributes




    properties(PropertyType='int32 scalar')
        PersistenceLevel=int32(1);
    end

    properties(PropertyType='logical scalar')
        IsPersistenceLevelInstanceSpecific=false;
    end


    properties(Hidden,Transient,PropertyType='char')
        Owner='';
        DefinitionFile='';
    end

    properties(Hidden,Transient,PropertyType='logical scalar')
        IsOwnerInstanceSpecific=false;
        IsDefinitionFileInstanceSpecific=false;
    end

    properties(Hidden,Transient,SetAccess=private,PropertyType='logical scalar')
        IssueWarning=false;
    end

    methods

        function obj=CSCTypeAttributes_Unstructed
            mlock;
            addlistener(obj,'Owner','PostSet',@obj.setOwnerEvent);
        end

        function setOwnerEvent(obj,src,event)%#ok
            obj.IssueWarning=true;
        end


        function props=getInstanceSpecificProps(hObj)


            props=[];

            if hObj.IsOwnerInstanceSpecific
                ptmp=findprop(hObj,'Owner');
                props=[props;ptmp];
            end

            if hObj.IsDefinitionFileInstanceSpecific
                ptmp=findprop(hObj,'DefinitionFile');
                props=[props;ptmp];
            end

            if hObj.IsPersistenceLevelInstanceSpecific
                ptmp=findprop(hObj,'PersistenceLevel');
                props=[props;ptmp];
            end
        end


        function set.DefinitionFile(obj,val)
            newVal=strtrim(val);
            [errTxt,hasDelimiters]=slprivate('check_generated_filename',newVal,'.c');
            if hasDelimiters
                errTxt=[DAStudio.message('Simulink:mpt:MPTDelimiterUnAllowed'),errTxt];
            end
            if~isempty(errTxt)&&~isequal(errTxt,'File name empty.')
                DAStudio.error('Simulink:mpt:MPTSLGenMsg',errTxt);
            end

            obj.DefinitionFile=newVal;
        end

    end
end
