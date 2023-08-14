classdef UniqueModelRefFactory<handle






    properties(Constant)
        AccelString=Simulink.ModelReference.internal.SimulationMode.SimulationModeAccel;
        SILString=Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL;
        PILString=Simulink.ModelReference.internal.SimulationMode.SimulationModePIL;
        TopModelString=Simulink.ModelReference.internal.SimulationMode.CodeInterfaceTopModel;
    end

    properties(Access=private)
IsUpdatingSimForRTW
    end

    methods
        function this=UniqueModelRefFactory(isUpdatingSimForRTW)

            this.IsUpdatingSimForRTW=isUpdatingSimForRTW;
        end

        function out=getUniqueModelRefs(this,existingModelRefs,modelRefs,simModes,codeInterfaces,isProtected)




            if isempty(existingModelRefs)
                existingModelRefs=Simulink.ModelReference.internal.UniqueModelRef.empty(1,0);
            end
            if isempty(modelRefs)
                modelRefs={};
                simModes={};
                codeInterfaces={};
            end


            isAccel=strcmp(simModes,this.AccelString);
            accel=unique(modelRefs(isAccel));


            isSIL=strcmp(simModes,this.SILString);
            isPIL=strcmp(simModes,this.PILString);

            if this.IsUpdatingSimForRTW



                isTop=false(size(modelRefs));
            else
                isTop=strcmp(codeInterfaces,this.TopModelString);
            end
            sil=unique(modelRefs(isSIL&~isTop));
            siltop=unique(modelRefs(isSIL&isTop));
            pil=unique(modelRefs(isPIL&~isTop));
            piltop=unique(modelRefs(isPIL&isTop));


            isNormal=~isAccel&~isSIL&~isPIL;
            normal=unique(modelRefs(isNormal));

            import Simulink.ModelReference.internal.UniqueModelRef
            out=[existingModelRefs...
            ,UniqueModelRef(normal,true,isProtected,'normal',false),...
            UniqueModelRef(accel,false,isProtected,this.AccelString,false),...
            UniqueModelRef(sil,false,isProtected,this.SILString,false),...
            UniqueModelRef(siltop,false,isProtected,this.SILString,true),...
            UniqueModelRef(pil,false,isProtected,this.PILString,false),...
            UniqueModelRef(piltop,false,isProtected,this.PILString,true)];
        end

        function out=getUniqueModelRefsFromCache(this,existingModelRefs,variantType,cache,modelType,isProtected)


            modelRefs=this.getFieldForVariant(variantType,cache,modelType);

            silMdlRefs=this.getFieldForVariant(variantType,cache,'silMdlRefs');
            silMdlRefs=intersect(silMdlRefs,modelRefs,'stable');

            pilMdlRefs=this.getFieldForVariant(variantType,cache,'pilMdlRefs');
            pilMdlRefs=intersect(pilMdlRefs,modelRefs,'stable');

            normalMdlRefs=this.getFieldForVariant(variantType,cache,'normalMdlRefs');
            normalMdlRefs=intersect(normalMdlRefs,modelRefs,'stable');

            accelMdlRefs=this.getFieldForVariant(variantType,cache,'accelMdlRefs');
            accelMdlRefs=intersect(accelMdlRefs,modelRefs,'stable');





            import Simulink.ModelReference.internal.UniqueModelRef
            out=[existingModelRefs,...
            UniqueModelRef(normalMdlRefs,false,isProtected,'normal',false),...
            UniqueModelRef(accelMdlRefs,false,isProtected,this.AccelString,false),...
            UniqueModelRef(silMdlRefs,false,isProtected,this.SILString,false),...
            UniqueModelRef(pilMdlRefs,false,isProtected,this.PILString,false)];
        end
    end

    methods(Static)






        function result=getFieldForVariant(variantType,infoStruct,fieldName)
            assert(ismember(variantType,{'CodeVar','ActiveVar',''}));



            fieldName=[fieldName,variantType];


            result=infoStruct.(fieldName);
        end
    end
end