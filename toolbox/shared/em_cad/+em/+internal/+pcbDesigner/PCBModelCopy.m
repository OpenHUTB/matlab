classdef PCBModelCopy<em.internal.pcbDesigner.AbstractPCBModel




    properties
InitialValue
    end

    methods
        function self=PCBModelCopy()

            sf=cad.ShapeFactory;
            of=cad.OperationsFactory;
            ff=[];
            self@em.internal.pcbDesigner.AbstractPCBModel(sf,of,ff);
        end
        function copyModel(self,Model)






            sessiondata=Model.createSessionData();


            self.setSessionData(sessiondata);


            self.InitialValue=cellfun(@(x)self.VariablesManager.get(x),...
            self.VariablesManager.getIndepVarNames,'UniformOutput',false);
        end

        function set(self,propName,Value)
            self.VariablesManager.set(propName,Value);
        end

        function val=get(self,propName)
            val=self.VariablesManager.get(propName);
        end

        function varNames=getVarNames(self)
            varNames=getIndepVarNames(self.VariablesManager);
            scalarIndex=cell2mat(cellfun(@(x)isscalar(self.VariablesManager.get(x)),varNames,'UniformOutput',false));
            varNames=varNames(scalarIndex);
        end

        function self=setValuesFcn(self,Name,Value)
            self.modelChanged=1;
            self.set(Name,Value)
            ant=self.getPCBObject();

        end

        function varargout=pattern(self,varargin)

            runMesh(self);
            ant=self.getPCBObject();
            varargout{1}=pattern(ant,varargin{:});


        end
        function varargout=sparameters(self,varargin)
            runMesh(self);
            ant=self.getPCBObject();
            varargout{1}=sparameters(ant,varargin{:});

        end

        function resetObject(self)







            varNames=self.getVarNames();
            for i=1:numel(varNames)
                self.set(varNames{i},self.InitialValue{i});
            end

        end

        function n=numFeed(self)
            n=numel(self.FeedStack);
        end

        function ant=optimize(self,varargin)
            pcbObj=self.createPCBObject();
            setMetaData(self,pcbObj);
            ant=optimize(pcbObj,varargin{:});
        end

        function setMetaData(self,pcbObj)
            varNames=self.getVarNames();
            pairedProps=cell(1,2*numel(varNames));
            pairedProps(1:2:numel(pairedProps))=varNames(1:end);
            pairedProps(2:2:numel(pairedProps))=cellfun(@(x)self,...
            pairedProps(2:2:numel(pairedProps)),'UniformOutput',false);
            setPairedProps(pcbObj,pairedProps);
            setValuesFcn(pcbObj,@(obj,propName,value,idx)self.parallelSetValuesFcn(obj,propName,value,idx));
        end

        function createGeometry(self)


        end

        function geom=getGeometry(self)
            ant=self.getPCBObject();
            createGeometry(ant);
            geom=getGeometry(ant);
        end


    end

    methods

        function pcbobj=parallelSetValuesFcn(self,obj,propNames,propValues,propIdx)

            for i=1:numel(propNames)
                eval([propNames{i},' = ',mat2str(propValues(str2num(propIdx{i}))),';']);

                self.VariablesManager.set(propNames{i},(propValues(str2num(propIdx{i}))));
            end

            pcbobj=self.createPCBObject();
            varNames=self.getVarNames();
            pairedProps=cell(1,2*numel(varNames));
            pairedProps(1:2:numel(pairedProps))=varNames(1:end);
            pairedProps(2:2:numel(pairedProps))=cellfun(@(x)pcbobj,...
            pairedProps(2:2:numel(pairedProps)),'UniformOutput',false);
            setPairedProps(pcbobj,pairedProps);

            obj.Layers=pcbobj.Layers;

            h_Data.PropNames=propNames;
            h_Data.PropValues=propValues;
            h_Data.Idx=propIdx;

            obj.h_setData(h_Data);
        end

    end
end