classdef GetSupportedLayersUtils<handle







    methods(Static)


        function classList=getClassListOnPath(returnAllLayersOnPath)


            if returnAllLayersOnPath

                nnetLayerClassTypes=["nnet","rl.layer"];
            else

                nnetLayerClassTypes=["nnet.cnn.layer","nnet.keras.layer","nnet.onnx.layer","rl.layer"];
            end

            classList=[];
            for iType=1:numel(nnetLayerClassTypes)
                classList=[classList;dltargets.internal.getAllClassesInPackage(nnetLayerClassTypes(iType))];%#ok<AGROW>
            end

        end










        function boolFlag=hasPublicStaticMethod(methodList,methodName)


            methodList=methodList(strcmp({methodList.Name},methodName));
            boolFlag=~isempty(methodList)&&methodList.Static;
        end


        function layerNames=formatLayerClassNames(layerClasses)


            layerClasses=cellstr(layerClasses);
            packagenames=cellfun(@(x)getPackageName(x),layerClasses,'UniformOutput',false);
            layerNames=cell(numel(layerClasses),1);
            for k=1:numel(layerClasses)
                if strcmpi(packagenames{k},'nnet.cnn.layer')
                    layerName=strrep(layerClasses{k},'nnet.cnn.layer.','');
                elseif strcmpi(packagenames{k},'rl.layer')
                    layerName=strrep(layerClasses{k},'rl.layer.','');
                else
                    layerName=layerClasses{k};
                end
                layerNames{k}=layerName;
            end

            function pkgName=getPackageName(ltype)
                out=regexp(ltype,'(.*)\.\w+$','tokens');
                if~isempty(out)
                    pkgName=out{1};
                else
                    pkgName='';
                end

            end

        end

    end

end
