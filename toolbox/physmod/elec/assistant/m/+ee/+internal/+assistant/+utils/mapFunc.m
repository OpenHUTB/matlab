function varargout=mapFunc(blockName,varargin)



    className=strcat(blockName,'_class');
    varargin=varargin{:};

    objName=matlab.lang.makeValidName(gcb);
    eval(['persistent ',objName]);

    if nargin==2&&isstruct(varargin)

        map=eval(className);
        map.objSetPath(varargin);
        map.objGetDropdown(varargin);
        map.objGetParam(varargin);
        map.OldBlockName=gcb;
        if strcmp(get_param(gcb,'SourceType'),'PSB option menu block')
            map.SourceType='powergui';
        else
            map.SourceType=get_param(gcb,'SourceType');
        end
        logObj=ElecAssistantLog.getInstance();
        logObj.addMessage(map,'BlockLog');
        if ismethod(map,'objDropdownMapping')
            map.objDropdownMapping();
        end
        if ismethod(map,'objParamMappingDirect')
            map.objParamMappingDirect();
        end
        eval([objName,'=map;']);
        out=map.objSetOutput();
        varargout={out};

    elseif nargin==2&&~isempty(find_system(varargin,'flat'))

        blockName=varargin;
        switch get_param(bdroot(blockName),'BlockDiagramType')
        case 'library'
            if strncmp('elec_conv_',bdroot(blockName),length('elec_conv_'))

            else
                set_param(bdroot(blockName),'Lock','off');

                set_param(blockName,'ReferenceBlock','','AncestorBlock','');

                set_param(blockName,'LoadFcn','');

                thisObjName=matlab.lang.makeValidName(blockName);
                eval(['map =',thisObjName,';']);
                if ismethod(map,'iFinalLoadFcn')
                    map.iFinalLoadFcn;
                else
                    set_param(blockName,'Mask','off');
                end
            end
        case 'model'

            set_param(blockName,'ReferenceBlock','','AncestorBlock','');

            set_param(blockName,'LoadFcn','');

            thisObjName=matlab.lang.makeValidName(blockName);
            eval(['map =',thisObjName,';']);
            if ismethod(map,'iFinalLoadFcn')
                map.iFinalLoadFcn;
            else
                set_param(blockName,'Mask','off');
            end
        otherwise
        end
        varargout={''};
    end

end

