classdef SystemObjectParameterSchema<handle






    properties

        propName;
        MaxNumColsInGrid=10;
        sysobjectParameterSchema;
        SystemObjectParameterExpression={};
    end
    properties(Hidden)
        Platform;
        System;
    end

    methods

        function obj=SystemObjectParameterSchema(blockH,propName)


            obj.Platform=blockH;

            obj.propName=propName;

        end

        function set.Platform(obj,blockH)
            obj.Platform=matlab.system.ui.SimulinkDescriptor(blockH);
        end

        function s=getSystemObjectParamStruct(obj)
            blockSysObjName=obj.System;


            groups=eval([blockSysObjName,'.getDisplayPropertyGroups(','''',blockSysObjName,'''',')']);


            metaClass=eval(['meta.class.fromName(','''',blockSysObjName,'''',')']);

            allDispPropsCellArray=cell(40,1);
            dIndx=1;
            for kndx=1:length(groups)
                grp=groups(kndx);
                if isa(grp,'matlab.system.display.Section')||...
                    (isa(grp,'matlab.system.display.SectionGroup')&&isempty(grp.Sections))||...
                    (isa(grp,'matlab.system.display.internal.DataTypesGroup'))
                    allDispPropsCellArray{dIndx}=grp.getDisplayProperties(metaClass);
                    dIndx=dIndx+1;
                else

                    for sIndx=1:length(grp.Sections)
                        sec=grp.Sections(sIndx);
                        allDispPropsCellArray{dIndx}=sec.getDisplayProperties(metaClass);
                        dIndx=dIndx+1;
                    end
                end
            end

            allDispProps=[allDispPropsCellArray{:}];


            prop=allDispProps(strcmp({allDispProps.Name},obj.propName));
            assert(length(prop)==1,'sysobjectParamRenderer.getSystemObjectParamStruct: more than one property found from group');



            dm=matlab.system.ui.BlockDialogManager.getInstance;
            dynDialog=dm.create(obj.Platform.BlockHandle);


            dynDialog.IsUsingMasking=true;


            [propItems,~]=dynDialog.getSystemObjectPropertySchema(prop,1);

            dynDialog.IsUsingMasking=false;


            s=struct('Type','panel');
            s.Items=propItems;
            s.Tag=obj.propName;



            maxRows=1;
            maxCols=1;
            for kndx=1:length(propItems)
                maxRows=max(maxRows,max(propItems{kndx}.RowSpan));
                maxCols=max(maxCols,max(propItems{kndx}.ColSpan));
            end
            s.LayoutGrid=[maxRows,maxCols];

        end

        function[]=setValue(~,~,~,property,~)


            if(property.IsLogical)
            end
        end

        function val=get.System(obj)

            val=obj.Platform.getSystemObjectName();
        end

    end

    methods(Static)
        function PropSetSystemObject(blockH,propValue,property,propInfo,tag)



            dm=matlab.system.ui.BlockDialogManager.getInstance;
            dynDialog=dm.create(blockH);
            dynDialog.IsUsingMasking=true;
            dynDialog.propSetSystemObject([],propValue,property,propInfo);
            dynDialog.IsUsingMasking=false;
        end

        function expression=getSystemObjectParamExpression(blockH,paramName)
            dm=matlab.system.ui.BlockDialogManager.getInstance;
            expression='';
            dynDialog=dm.get(blockH);
            if(~isempty(dynDialog)&&(isKey(dynDialog.SystemObjectParamExpression,paramName)))
                expression=dynDialog.SystemObjectParamExpression(paramName);
            end
        end
    end
end
