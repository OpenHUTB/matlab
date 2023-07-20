classdef UpdateTypeMapVisitor<dds.internal.BaseVisitor






    properties
UseShortNameForType
SystemTypeMap
    end


    methods
        function h=UpdateTypeMapVisitor(varargin)
            h@dds.internal.BaseVisitor();
            h.reset(varargin{:});
        end

        function reset(h,varargin)
            reset@dds.internal.BaseVisitor(h);
            h.UseShortNameForType=false;
            h.SystemTypeMap=[];
        end

        function status=visitModel(h,mf0Model)
            status=visitModel@dds.internal.BaseVisitor(h,mf0Model);
        end

        function status=visitSystem(h,syselem)
            h.UseShortNameForType=dds.internal.isSystemUsingShortName(mf.zero.getModel(syselem),syselem);
            if h.UseShortNameForType
                h.SystemTypeMap=syselem.TypeMap;
            end

            status=h.visitTypeLibraries(syselem);
        end

        function status=visitModelForOnlyElements(h,mf0Model)
            h.UseShortNameForType=dds.internal.isSystemUsingShortName(mf0Model);
            if h.UseShortNameForType
                systemInModel=dds.internal.getSystemInModel(mf0Model);
                h.SystemTypeMap=systemInModel.TypeMap;
            end
            status=true;
        end

        function fullName=addToTypeMap(h,theObj,fullName)
            if h.UseShortNameForType&&isempty(theObj.TypeMapEntryRef)&&...
                ~any(matches(h.SystemTypeMap.Map.keys,fullName))



                h.SystemTypeMap.createIntoMap(struct('FullName',fullName,'Element',theObj));

            end
        end

        function status=visitModule(h,theObj)



            if h.UseShortNameForType&&isempty(theObj.TypeMapEntryRef)
                fullName=dds.internal.getFullNameForType(theObj);
                h.addToTypeMap(theObj,fullName);
            end
            status=visitModule@dds.internal.BaseVisitor(h,theObj);
        end

        function status=visitConst(h,theObj)
            fullName=dds.internal.getFullNameForType(theObj);
            h.addToTypeMap(theObj,fullName);
            status=visitConst@dds.internal.BaseVisitor(h,theObj);
        end

        function status=visitEnum(h,theObj)
            fullName=dds.internal.getFullNameForType(theObj);
            h.addToTypeMap(theObj,fullName);
            status=visitEnum@dds.internal.BaseVisitor(h,theObj);
        end

        function status=visitAlias(h,theObj)
            fullName=dds.internal.getFullNameForType(theObj);
            h.addToTypeMap(theObj,fullName);
            status=visitAlias@dds.internal.BaseVisitor(h,theObj);
        end

        function status=visitStruct(h,theObj)
            fullName=dds.internal.getFullNameForType(theObj);
            h.addToTypeMap(theObj,fullName);
            status=visitStruct@dds.internal.BaseVisitor(h,theObj);
        end
    end
end
