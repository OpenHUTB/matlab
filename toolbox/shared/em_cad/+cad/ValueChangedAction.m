classdef ValueChangedAction<cad.Actions




    methods

        function self=ValueChangedAction(Model,evt)


            self.Type=evt.Data.Property;
            self.Model=Model;
            self.ActionObjectType=evt.Data.Type;
            switch self.ActionObjectType
            case 'Shape'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'Operation'
            case 'Layer'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'BoardShape'
            case 'Feed'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'Via'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'Load'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'LayerTree'
                self.ActionInfo.Id=evt.Data.Id;
                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'CanvasSettings'

                self.ActionInfo.Data=evt.Data;
            case 'AnalysisSettings'

                self.ActionInfo.Data=evt.Data;
            case 'PCBAntenna'

                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'FeedTree'

                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            case 'ViaTree'

                self.ActionInfo.Property=evt.Data.Property;
                self.ActionInfo.PreviousValue=evt.Data.PreviousValue;
                self.ActionInfo.Value=evt.Data.Value;
            end
        end

        function undo(self)
            switch self.ActionObjectType
            case 'Shape'



                info=self.ActionInfo;
                tmp=info.PreviousValue;
                info.PreviousValue=info.Value;
                info.Value=tmp;
                shapeobj=getShapeObj(self.Model,self.ActionInfo.Id);
                if any(strcmpi(fields(shapeobj.PropertyValueMap),info.Property))
                    self.Model.VariablesManager.setValueToObject(shapeobj,info.Property,info.Value);
                else
                    changeValue(shapeobj,info);
                end
                shapeParentObj=getFinalShapeParent(self.Model,shapeobj);
                shapePropertyChanged(self.Model,shapeParentObj);
                shapePropertyChanged(self.Model,shapeobj);
                layerparent=getFinalParent(self.Model,shapeobj);
                layerUpdated(self.Model,layerparent);
            case 'Layer'


                layerobj=self.ActionObject;


                if strcmpi(layerobj.MaterialType,'Dielectric')
                    if strcmpi(self.ActionInfo.Property,'DielectricType')
                        layerobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                        self.Model.VariablesManager.setValueToObject(layerobj,'EpsilonR',self.ActionInfo.PrevEpsilonR);
                        self.Model.VariablesManager.setValueToObject(layerobj,'LossTangent',self.ActionInfo.PrevLossTangent);
                    elseif strcmpi(self.ActionInfo.Property,'Thickness')
                        previousPropertyVal=layerobj.(self.ActionInfo.Property);
                        self.Model.VariablesManager.setValueToObject(layerobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                        currentpropertyVal=layerobj.(self.ActionInfo.Property);
                        thicknessChanged(self.Model,layerobj,previousPropertyVal,currentpropertyVal);
                    elseif any(strcmpi(self.ActionInfo.Property,{'LossTangent','EpsilonR'}))
                        layerobj.DielectricType=self.ActionInfo.DielectricType;
                        self.Model.VariablesManager.setValueToObject(layerobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                        self.ActionObject=layerobj;
                    else
                        layerobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                    end
                else

                    layerobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                end

                layerPropertyChanged(self.Model,layerobj);
            case 'Feed'
                feedobj=self.ActionObject;

                if any(strcmpi(fields(feedobj.PropertyValueMap),self.ActionInfo.Property))
                    self.Model.VariablesManager.setValueToObject(feedobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                else

                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        if feedobj.StartLayer.Id~=feedobj.StopLayer.Id
                            removeFeed(feedobj.(self.ActionInfo.Property),feedobj);
                        end
                        removeFeed(feedobj.(self.ActionInfo.Property),feedobj);
                        layerUpdated(self.Model,feedobj.(self.ActionInfo.Property));

                        layerobj=findlayerobj(self.Model,self.ActionInfo.PreviousValue.Id);
                        feedobj.(self.ActionInfo.Property)=layerobj;
                        addFeed(feedobj.(self.ActionInfo.Property),feedobj)
                        layerUpdated(self.Model,layerobj);
                    else
                        feedobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                    end

                end
                if any(strcmpi(self.ActionInfo.Property,{'FeedVoltage','FeedPhase'}))
                    self.Model.updateFeedVoltageAndPhase();
                end
                feedPropertyChanged(self.Model,feedobj);

            case 'Via'
                viaobj=self.ActionObject;

                if any(strcmpi(fields(viaobj.PropertyValueMap),self.ActionInfo.Property))
                    self.Model.VariablesManager.setValueToObject(viaobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                else

                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        if viaobj.StartLayer.Id~=viaobj.StopLayer.Id
                            removeVia(viaobj.(self.ActionInfo.Property),viaobj);
                        end
                        removeVia(viaobj.(self.ActionInfo.Property),viaobj);
                        layerUpdated(self.Model,viaobj.(self.ActionInfo.Property));
                        layerobj=findlayerobj(self.Model,self.ActionInfo.PreviousValue.Id);
                        viaobj.(self.ActionInfo.Property)=layerobj;
                        addVia(viaobj.(self.ActionInfo.Property),viaobj)
                        layerUpdated(self.Model,layerobj);
                    else
                        viaobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                    end
                end
                viaPropertyChanged(self.Model,viaobj);
            case 'Load'
                loadobj=self.ActionObject;

                if any(strcmpi(fields(loadobj.PropertyValueMap),self.ActionInfo.Property))
                    if any(strcmpi(self.ActionInfo.Property,{'Frequency','Impedance'}))
                        self.Model.VariablesManager.setValueToObject(loadobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue,1);
                    else
                        self.Model.VariablesManager.setValueToObject(loadobj,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                    end
                else
                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        removeLoad(loadobj.('StartLayer'),loadobj);
                        removeLoad(loadobj.('StopLayer'),loadobj);
                        layerUpdated(self.Model,loadobj.('StartLayer'));
                        layerobj=findlayerobj(self.Model,self.ActionInfo.PreviousValue.Id);
                        loadobj.('StartLayer')=layerobj;
                        loadobj.('StopLayer')=layerobj;
                        addLoad(loadobj.('StartLayer'),loadobj);
                        layerUpdated(self.Model,layerobj);
                    else
                        loadobj.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                    end
                end
                loadPropertyChanged(self.Model,loadobj);
            case 'CanvasSettings'
                self.Model.Metal=self.ActionInfo.Metal;
                self.Model.Units=self.ActionInfo.Units;
                self.Model.Grid=self.ActionInfo.Grid;
                settingsUpdated(self.Model);
            case 'AnalysisSettings'
                self.Model.Plot=self.ActionInfo.Plot;
                self.Model.Mesh=self.ActionInfo.Mesh;
                settingsUpdated(self.Model);
            case 'LayerTree'
                self.Model.Metal=self.ActionInfo.Metal;
                settingsUpdated(self.Model);
            case 'PCBAntenna'
                if any(strcmpi(self.ActionInfo.Property,{'FeedDiameter','ViaDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                end
                if strcmpi(self.ActionInfo.Property,'FeedDiameter')
                    feedDiameterChanged(self.Model);
                elseif strcmpi(self.ActionInfo.Property,'ViaDiameter')
                    viaDiameterChanged(self.Model);
                end
                pcbPropertyChanged(self.Model);
            case 'FeedTree'
                if any(strcmpi(self.ActionInfo.Property,{'FeedDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                end
                if strcmpi(self.ActionInfo.Property,'FeedDiameter')
                    feedDiameterChanged(self.Model);
                end
                feedTreePropertyChanged(self.Model);
            case 'ViaTree'
                if any(strcmpi(self.ActionInfo.Property,{'ViaDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.PreviousValue);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.PreviousValue;
                end
                if strcmpi(self.ActionInfo.Property,'ViaDiameter')
                    viaDiameterChanged(self.Model);
                end
                viaTreePropertyChanged(self.Model);

            end
        end

        function execute(self)
            switch self.ActionObjectType
            case 'Shape'
                shapeobj=getShapeObj(self.Model,self.ActionInfo.Id);
                if any(strcmpi(fields(shapeobj.PropertyValueMap),self.ActionInfo.Property))

                    self.Model.VariablesManager.setValueToObject(shapeobj,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    changeValue(shapeobj,self.ActionInfo);
                end
                shapeParentObj=getFinalShapeParent(self.Model,shapeobj);
                shapePropertyChanged(self.Model,shapeParentObj);
                shapePropertyChanged(self.Model,shapeobj);
                layerparent=getFinalParent(self.Model,shapeobj);
                layerUpdated(self.Model,layerparent);
            case 'Layer'
                layerobj=findlayerobj(self.Model,self.ActionInfo.Id);

                if strcmpi(layerobj.MaterialType,'Dielectric')
                    if strcmpi(self.ActionInfo.Property,'DielectricType')
                        layerobj.(self.ActionInfo.Property)=self.ActionInfo.Value;


                        if~strcmpi(self.ActionInfo.Value,'Custom')
                            dc=DielectricCatalog;
                            props=dc.Materials(strcmpi(dc.Materials{:,1},self.ActionInfo.Value),:);



                            if~isempty(layerobj.PropertyValueMap.EpsilonR)
                                self.ActionInfo.PrevEpsilonR=layerobj.PropertyValueMap.EpsilonR;
                            else
                                self.ActionInfo.PrevEpsilonR=layerobj.EpsilonR;
                            end
                            if~isempty(layerobj.PropertyValueMap.LossTangent)
                                self.ActionInfo.PrevLossTangent=layerobj.PropertyValueMap.LossTangent;
                            else
                                self.ActionInfo.PrevLossTangent=layerobj.LossTangent;
                            end
                            self.Model.VariablesManager.setValueToObject(layerobj,'EpsilonR',props.Relative_Permittivity);
                            self.Model.VariablesManager.setValueToObject(layerobj,'LossTangent',props.Loss_Tangent);

                        end
                    elseif strcmpi(self.ActionInfo.Property,'Thickness')



                        previousPropertyVal=layerobj.(self.ActionInfo.Property);
                        self.Model.VariablesManager.setValueToObject(layerobj,self.ActionInfo.Property,self.ActionInfo.Value);

                        currentpropertyVal=layerobj.(self.ActionInfo.Property);
                        thicknessChanged(self.Model,layerobj,previousPropertyVal,currentpropertyVal);
                    elseif any(strcmpi(self.ActionInfo.Property,{'LossTangent','EpsilonR'}))
                        self.ActionInfo.DielectricType=layerobj.DielectricType;
                        layerobj.DielectricType='Custom';

                        self.Model.VariablesManager.setValueToObject(layerobj,self.ActionInfo.Property,self.ActionInfo.Value);
                        self.ActionObject=layerobj;
                    else
                        layerobj.(self.ActionInfo.Property)=self.ActionInfo.Value;
                        self.ActionObject=layerobj;
                    end

                else
                    layerobj.(self.ActionInfo.Property)=self.ActionInfo.Value;

                end
                layerPropertyChanged(self.Model,layerobj);
                self.ActionObject=layerobj;
            case 'Feed'
                feedobj=getFeedObj(self.Model,self.ActionInfo.Id);
                if any(strcmpi(fields(feedobj.PropertyValueMap),self.ActionInfo.Property))
                    self.Model.VariablesManager.setValueToObject(feedobj,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        layerobj=findlayerobj(self.Model,self.ActionInfo.Value.Id);
                        if feedobj.StartLayer.Id~=feedobj.StopLayer.Id
                            removeFeed(feedobj.(self.ActionInfo.Property),feedobj);
                            layerUpdated(self.Model,feedobj.(self.ActionInfo.Property));
                        end
                        feedobj.(self.ActionInfo.Property)=layerobj;
                        addFeed(feedobj.(self.ActionInfo.Property),feedobj);
                        layerUpdated(self.Model,feedobj.(self.ActionInfo.Property));
                    else
                        feedobj.(self.ActionInfo.Property)=self.ActionInfo.Value;
                    end
                end
                if any(strcmpi(self.ActionInfo.Property,{'FeedVoltage','FeedPhase'}))
                    self.Model.updateFeedVoltageAndPhase();
                end
                feedPropertyChanged(self.Model,feedobj);
                self.ActionObject=feedobj;
            case 'Via'
                viaobj=getViaObj(self.Model,self.ActionInfo.Id);
                if any(strcmpi(fields(viaobj.PropertyValueMap),self.ActionInfo.Property))
                    self.Model.VariablesManager.setValueToObject(viaobj,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        layerobj=findlayerobj(self.Model,self.ActionInfo.Value.Id);
                        if viaobj.StartLayer.Id~=viaobj.StopLayer.Id
                            removeVia(viaobj.(self.ActionInfo.Property),viaobj);
                            layerUpdated(self.Model,viaobj.(self.ActionInfo.Property));
                        end
                        viaobj.(self.ActionInfo.Property)=layerobj;
                        addVia(viaobj.(self.ActionInfo.Property),viaobj)
                        layerUpdated(self.Model,viaobj.(self.ActionInfo.Property));
                    else
                        viaobj.(self.ActionInfo.Property)=self.ActionInfo.Value;
                    end
                end
                viaPropertyChanged(self.Model,viaobj);
                self.ActionObject=viaobj;
            case 'Load'
                loadobj=getLoadObj(self.Model,self.ActionInfo.Id);
                if any(strcmpi(fields(loadobj.PropertyValueMap),self.ActionInfo.Property))
                    if any(strcmpi(self.ActionInfo.Property,{'Frequency','Impedance'}))
                        self.Model.VariablesManager.setValueToObject(loadobj,self.ActionInfo.Property,self.ActionInfo.Value,1);
                    else
                        self.Model.VariablesManager.setValueToObject(loadobj,self.ActionInfo.Property,self.ActionInfo.Value);
                    end
                else
                    if any(strcmpi(self.ActionInfo.Property,{'StartLayer','StopLayer'}))
                        layerobj=findlayerobj(self.Model,self.ActionInfo.Value.Id);
                        removeLoad(loadobj.('StartLayer'),loadobj);
                        removeLoad(loadobj.('StopLayer'),loadobj);
                        layerUpdated(self.Model,loadobj.('StartLayer'));
                        loadobj.('StartLayer')=layerobj;
                        loadobj.('StopLayer')=layerobj;
                        addLoad(loadobj.('StartLayer'),loadobj);
                    else
                        loadobj.(self.ActionInfo.Property)=self.ActionInfo.Value;
                    end
                end
                loadPropertyChanged(self.Model,loadobj);
                self.ActionObject=loadobj;
            case 'CanvasSettings'
                self.ActionInfo.Metal=self.Model.Metal;
                self.ActionInfo.Units=self.Model.Units;
                self.ActionInfo.Grid=self.Model.Grid;
                self.Model.Metal=self.ActionInfo.Data.Metal;
                self.Model.Units=self.ActionInfo.Data.Units;
                self.Model.Grid=self.ActionInfo.Data.Grid;
                settingsUpdated(self.Model);
            case 'AnalysisSettings'
                self.ActionInfo.Plot=self.Model.Plot;
                self.ActionInfo.Mesh=self.Model.Mesh;
                self.Model.Plot=self.ActionInfo.Data.Plot;
                self.Model.Mesh=self.ActionInfo.Data.Mesh;
                settingsUpdated(self.Model);
            case 'LayerTree'
                self.ActionInfo.Metal=self.Model.Metal;
                self.Model.Metal.(self.ActionInfo.Property)=self.ActionInfo.Value;
                if strcmpi(self.ActionInfo.Property,'Conductivity')
                    self.Model.Metal.Type='Custom';
                elseif strcmpi(self.ActionInfo.Property,'Type')&&~strcmpi(self.ActionInfo.Value,'Custom')
                    mc=MetalCatalog;
                    idx=strcmpi(mc.Materials.Name,self.ActionInfo.Value);
                    self.Model.Metal.Thickness=(mc.Materials.Thickness(idx)*getMilsConvertFactor(...
                    self,mc.Materials.Units{idx}));
                    self.Model.Metal.Conductivity=(mc.Materials.Conductivity(idx));
                end
                settingsUpdated(self.Model);
            case 'PCBAntenna'
                if any(strcmpi(self.ActionInfo.Property,{'FeedDiameter','ViaDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.Value;
                end
                if strcmpi(self.ActionInfo.Property,'FeedDiameter')
                    feedDiameterChanged(self.Model);
                elseif strcmpi(self.ActionInfo.Property,'ViaDiameter')
                    viaDiameterChanged(self.Model);
                end
                pcbPropertyChanged(self.Model);
            case 'FeedTree'
                if any(strcmpi(self.ActionInfo.Property,{'FeedDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.Value;
                end
                if strcmpi(self.ActionInfo.Property,'FeedDiameter')
                    feedDiameterChanged(self.Model);
                end
                feedTreePropertyChanged(self.Model);
            case 'ViaTree'
                if any(strcmpi(self.ActionInfo.Property,{'ViaDiameter'}))
                    self.Model.VariablesManager.setValueToObject(self.Model.VarProperties,self.ActionInfo.Property,self.ActionInfo.Value);
                else
                    self.Model.(self.ActionInfo.Property)=self.ActionInfo.Value;
                end

                if strcmpi(self.ActionInfo.Property,'ViaDiameter')
                    viaDiameterChanged(self.Model);
                end
                viaTreePropertyChanged(self.Model);

            end
        end

        function fact=getMilsConvertFactor(self,val)
            switch val
            case 'mil'
                fact=1;
            case 'm'
                fact=39.37*1000;
            case 'cm'
                fact=39.37*10;
            case 'um'
                fact=39.37*1e-3;
            case 'in'
                fact=1000;
            case 'mm'
                fact=39.37;
            end
        end
    end
end
