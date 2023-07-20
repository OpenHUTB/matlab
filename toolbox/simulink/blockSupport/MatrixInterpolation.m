classdef(StrictDefaults)MatrixInterpolation<matlab.System %#codegen

    properties(Nontunable)
        InterpMethod='Linear';

        ExtrapMethod='Clip';

        InterpolateDimension='1';

        TableData=1:1:10;
    end

    properties(Nontunable,Access=private)
        GridSize;
        IndexSelector;
        I1;
        I2;
        L;
        nD=3;
        LinearExtrap=false;
        NearestInterp=true;
        tableSize;
        numIn;
        WeightDataType;
        IndexDataType;
        sizeOut;
        DataDim;
        dataLength;
        DataSize;
        isScalarTable;
        is1DVectorTable;
    end

    properties(Access=private)
        Origin;
        Fraction;
        FractionComp;
    end

    properties(Hidden,Transient)
        InterpMethodSet=...
        matlab.system.internal.MessageCatalogSet({'SimulinkBlocks:dialog:Flat_CB','SimulinkBlocks:dialog:Nearest_CB','SimulinkBlocks:dialog:Linear_CB'});

        ExtrapMethodSet=...
        matlab.system.internal.MessageCatalogSet({'SimulinkBlocks:dialog:Clip_CB','SimulinkBlocks:dialog:Linear_CB'});

        InterpolateDimensionSet=...
        matlab.system.StringSet({'1','2','3'});
    end

    methods
        function obj=MatrixInterpolation(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)

        function validatePropertiesImpl(obj)

            if((strcmp(obj.InterpMethod,'Flat')||strcmp(obj.InterpMethod,'Nearest'))&&strcmp(obj.ExtrapMethod,'Linear'))
                error(message('SimulinkBlocks:MatrixInterp:ClipOnlyMethod'));
            end

            obj.tableSize=size(obj.TableData);



            if length(obj.tableSize)<str2double(obj.InterpolateDimension)
                error(message('SimulinkBlocks:MatrixInterp:TableDimensionMismatch'));
            end


            if(obj.tableSize(end)==1)
                error(message('SimulinkBlocks:MatrixInterp:NonscalarBreakpoints'));
            end


            if(length(obj.tableSize)==str2double(obj.InterpolateDimension))
                obj.isScalarTable=true;
            else
                obj.isScalarTable=false;
            end

            if(length(obj.tableSize)==str2double(obj.InterpolateDimension)+1)
                obj.is1DVectorTable=true;
            else
                obj.is1DVectorTable=false;
            end

            if~isreal(obj.TableData)
                error(message('SimulinkBlocks:MatrixInterp:NoComplexTableData'));
            end
        end


        function validateInputsImpl(obj,varargin)

            obj.numIn=nargin-1;

            for i=1:obj.numIn
                if(length(varargin{i})~=1)
                    error(message('SimulinkBlocks:MatrixInterp:InputMustBeScalar'));
                end
                if~isreal(varargin{i})
                    error(message('SimulinkBlocks:MatrixInterp:InputMustBeReal'));
                end
            end


            for i=1:obj.numIn/2
                if~isa(varargin{2*i-1},'int8')&&~isa(varargin{2*i-1},'int16')&&~isa(varargin{2*i-1},'int32')&&~isa(varargin{2*i-1},'uint8')&&~isa(varargin{2*i-1},'uint16')&&~isa(varargin{2*i-1},'uint32')
                    error(message('SimulinkBlocks:MatrixInterp:IndexMustBeIntegerType'));
                end
                if~(isa(varargin{2*i},'double')||isa(varargin{2*i},'single'))
                    error(message('SimulinkBlocks:MatrixInterp:FractionMustBeFloatType'));
                end

                if i<obj.numIn/2
                    if~strcmp(class(varargin{2*i-1}),class(varargin{2*i+1}))
                        error(message('SimulinkBlocks:MatrixInterp:SameIndexTypes'));
                    end
                    if~strcmp(class(varargin{2*i}),class(varargin{2*i+2}))
                        error(message('SimulinkBlocks:MatrixInterp:SameFractionTypes'))
                    end
                end
            end


            if~strcmp(class(obj.TableData),class(varargin{2}))
                error(message('SimulinkBlocks:MatrixInterp:TableTypeMustMatchFractionType'));
            end
        end

        function setupImpl(obj,varargin)
            obj.GridSize=obj.tableSize(end-str2double(obj.InterpolateDimension)+1:end);
            obj.nD=length(obj.GridSize);
            obj.IndexDataType=class(varargin{1});
            obj.WeightDataType=class(varargin{2});



            if(obj.isScalarTable)
                obj.sizeOut=1;
            elseif(obj.is1DVectorTable)
                obj.sizeOut=[1,obj.tableSize(1)];
            else
                obj.sizeOut=obj.tableSize(1:1:(end-str2double(obj.InterpolateDimension)));
            end

            if(obj.isScalarTable)


                obj.DataDim=1;
                obj.dataLength=1;
                obj.DataSize=1;
            elseif(obj.is1DVectorTable)



                obj.DataDim=2;
                obj.dataLength=obj.tableSize(1);
                obj.DataSize=[1,obj.tableSize(1)];
            else
                obj.DataDim=length(obj.tableSize)-str2double(obj.InterpolateDimension);

                obj.dataLength=prod(obj.tableSize(1:obj.DataDim));
                obj.DataSize=obj.tableSize(1:obj.DataDim);
            end

            len=2^obj.nD;
            if obj.nD>1
                obj.IndexSelector=reshape(1:len,2*ones(1,obj.nD));
            else
                obj.IndexSelector=1:len;
            end

            obj.I1=1:2:len-1;
            obj.I2=2:2:len;

            obj.L=[1,cumprod(obj.GridSize(1:end-1))];

            obj.LinearExtrap=strcmp(obj.ExtrapMethod,'Linear');
            obj.NearestInterp=strcmp(obj.InterpMethod,'Nearest');

            obj.Origin=zeros(1,obj.numIn/2,obj.IndexDataType);
            obj.Fraction=zeros(1,obj.numIn/2,obj.WeightDataType);
            obj.FractionComp=zeros(1,obj.numIn/2,obj.WeightDataType);
        end

        function Out=stepImpl(obj,varargin)

            nd=obj.nD;

            lcl_input=varargin;


            for i=1:nd

                cond1=varargin{2*i-1}>=obj.GridSize(i);
                cond2=varargin{2*i-1}<0;
                if cond1
                    coder.internal.errorIf(cond1,'SimulinkBlocks:MatrixInterp:IndexOutOfRange');


                elseif cond2
                    coder.internal.errorIf(cond2,'SimulinkBlocks:MatrixInterp:IndexNonnegative');

                end


                if coder.target('MATLAB')
                    isInLinearization=obj.isInMATLABSystemBlock&&(~isempty(bdroot)&&...
                    isequal(get_param(bdroot,'AnalyticLinearization'),'on'));
                else
                    isInLinearization=false;
                end


                cond3=varargin{2*i}>1&&...
                ((varargin{2*i-1}~=obj.GridSize(i)-1)&&...
                (varargin{2*i-1}~=obj.GridSize(i)-2));
                cond4=varargin{2*i}<0&&(varargin{2*i-1}~=0);
                if cond3&&~isInLinearization
                    coder.internal.errorIf(cond3,'SimulinkBlocks:MatrixInterp:FractionOutOfRange');

                elseif cond4&&~isInLinearization
                    coder.internal.errorIf(cond4,'SimulinkBlocks:MatrixInterp:FractionNonnegative');

                end


                if coder.target('MATLAB')

                    if isInLinearization
                        if cond3
                            lcl_input{2*i}=varargin{2*i}-1;
                            lcl_input{2*i-1}=varargin{2*i-1}+1;
                        end

                        if cond4
                            lcl_input{2*i}=varargin{2*i}+1;
                            lcl_input{2*i-1}=varargin{2*i-1}-1;
                        end
                        lcl_input{2*i-1}=round(lcl_input{2*i-1});
                    end
                end
            end


            for i=1:obj.numIn/2
                obj.Origin(i)=lcl_input{2*i-1};
                obj.Fraction(i)=lcl_input{2*i};
            end


            obj.Origin=obj.Origin+1;

            AtEdge=(obj.GridSize==obj.Origin);
            AtOrigin=(obj.Origin==1)&(obj.Fraction<0);

            if strcmp(obj.InterpMethod,'Flat')


                I=subscript2Index(obj,obj.Origin,nd,obj.GridSize(1));
            elseif strcmp(obj.InterpMethod,'Nearest')

                Loc=obj.Origin;

                PickNext=~AtEdge&obj.Fraction>=0.5;
                Loc(PickNext)=Loc(PickNext)+1;
                I=subscript2Index(obj,Loc,nd,obj.GridSize(1));
            else


                if any(AtEdge)
                    if obj.LinearExtrap
                        obj.Origin(AtEdge)=obj.Origin(AtEdge)-1;
                        obj.Fraction(AtEdge)=obj.Fraction(AtEdge)+1;
                        AtEdge=false(1,nd);
                    else
                        obj.Fraction(AtEdge)=0;
                    end
                end

                if any(AtOrigin)
                    if~obj.LinearExtrap
                        obj.Fraction(AtOrigin&obj.Fraction<0)=0;
                    end
                end

                len=2^(nd);
                W=ones(len,1,obj.WeightDataType);
                I1=obj.I1;
                I2=obj.I2;
                obj.FractionComp=1-obj.Fraction;

                I=zeros(1,len);
                L=obj.L;
                I_=0;


                for ct=1:nd
                    I_=I_+L(ct)*(double(obj.Origin(ct))-1);
                end
                I(1)=I_+1;
                Off=1;
                for j=1:nd
                    if~AtEdge(j)
                        I((Off+1):2*Off)=I(1:Off)+L(j);
                    else
                        I((Off+1):2*Off)=I(1:Off);
                    end
                    Off=Off*2;
                end

                for ct=1:nd
                    iP=1:nd;
                    if ct>1
                        iP(1)=ct;
                        iP(2:ct)=1:ct-1;
                        iW2=permute(obj.IndexSelector,iP);
                    else
                        iW2=1:len;
                    end
                    W(iW2(I1))=W(iW2(I1))*obj.FractionComp(ct);
                    W(iW2(I2))=W(iW2(I2))*obj.Fraction(ct);
                end
            end


            if strcmp(obj.InterpMethod,'Linear')

                for i=1:len
                    I(i)=obj.dataLength*(I(i)-1);
                end

                if isa(obj.TableData,'single')
                    Out=single(zeros(obj.sizeOut));
                else
                    Out=zeros(obj.sizeOut);
                end
                for i=1:len
                    if(obj.DataDim==1)
                        Out=Out+obj.TableData(I(i)+1)*W(i);
                    else
                        Out=Out+reshape(obj.TableData((I(i)+1):(I(i)+obj.dataLength)),obj.DataSize)*W(i);
                    end
                end
            else
                I=obj.dataLength*(I-1);
                if isa(obj.TableData,'single')
                    Out=single(zeros(obj.sizeOut));
                else
                    Out=zeros(obj.sizeOut);
                end
                if obj.DataDim==1
                    Out=Out+obj.TableData(I+1);
                else
                    Out=Out+reshape(obj.TableData((I+1):(I+obj.dataLength)),obj.DataSize);
                end
            end
        end


        function I=subscript2Index(obj,Loc,nd,sz1)


            if nd==1
                I=double(Loc);
            elseif nd==2
                I=double(Loc(1)+(Loc(2)-1)*sz1);
            else
                L=obj.L;
                I_=0;



                for ct=1:nd
                    I_=I_+L(ct)*(double(Loc(ct))-1);
                end
                I=I_+1;
            end
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.GridSize=obj.GridSize;
                s.IndexSelector=obj.IndexSelector;
                s.I1=obj.I1;
                s.I2=obj.I2;
                s.L=obj.L;
                s.nD=obj.nD;
                s.LinearExtrap=obj.LinearExtrap;
                s.NearestInterp=obj.NearestInterp;
                s.tableSize=obj.tableSize;
                s.numIn=obj.numIn;
                s.WeightDataType=obj.WeightDataType;
                s.IndexDataType=obj.IndexDataType;
                s.sizeOut=obj.sizeOut;
                s.DataDim=obj.DataDim;
                s.dataLength=obj.dataLength;
                s.DataSize=obj.DataSize;
                s.isScalarTable=obj.isScalarTable;
                s.is1DVectorTable=obj.is1DVectorTable;
                s.Origin=obj.Origin;
                s.Fraction=obj.Fraction;
                s.FractionComp=obj.FractionComp;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.GridSize=s.GridSize;
                obj.IndexSelector=s.IndexSelector;
                obj.I1=s.I1;
                obj.I2=s.I2;
                obj.L=s.L;
                obj.nD=s.nD;
                obj.LinearExtrap=s.LinearExtrap;
                obj.NearestInterp=s.NearestInterp;
                obj.tableSize=s.tableSize;
                obj.numIn=s.numIn;
                obj.WeightDataType=s.WeightDataType;
                obj.IndexDataType=s.IndexDataType;
                obj.sizeOut=s.sizeOut;
                obj.DataDim=s.DataDim;
                obj.dataLength=s.dataLength;
                obj.DataSize=s.DataSize;
                obj.isScalarTable=s.isScalarTable;
                obj.is1DVectorTable=s.is1DVectorTable;
                obj.Origin=s.Origin;
                obj.Fraction=s.Fraction;
                obj.FractionComp=s.FractionComp;

            end
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        function numIn=getNumInputsImpl(obj)
            numIn=2*str2double(obj.InterpolateDimension);
        end

        function numOut=getNumOutputsImpl(~)
            numOut=1;
        end

        function sizeOut=getOutputSizeImpl(obj)
            obj.tableSize=size(obj.TableData);
            if obj.isScalarTable
                sizeOut=1;
            elseif obj.is1DVectorTable
                sizeOut=[1,obj.tableSize(1)];
            else
                sizeOut=obj.tableSize(1:1:(end-str2double(obj.InterpolateDimension)));
            end
        end

        function Out=isOutputFixedSizeImpl(~)
            Out=true;
        end

        function Out=getOutputDataTypeImpl(obj)
            if isa(obj.TableData,'single')
                Out='single';
            else
                Out='double';
            end
        end

        function Out=isOutputComplexImpl(~)
            Out=false;
        end

        function[name1,name2,name3,name4,name5,name6]=getInputNamesImpl(~)

            name1='k1';
            name2='f1';

            name3='k2';
            name4='f2';

            name5='k3';
            name6='f3';
        end

        function outputName=getOutputNamesImpl(~)
            outputName='';
        end

        function icon=getIconImpl(~)

            icon='MI';
        end
    end

    methods(Access=protected,Static)
        function header=getHeaderImpl

            header=matlab.system.display.Header(...
            'Title','Simulink:blocks:matrixInterpolationTitle',...
            'Text','Simulink:blocks:matrixInterpolationDesc',...
            'ShowSourceLink',false);
        end

        function group=getPropertyGroupsImpl


            paramList={'InterpMethod','ExtrapMethod','InterpolateDimension','TableData'};
            group=getDisplaySection('Simulink','blocks','Parameters',paramList);
        end
    end
end
function dispSection=getDisplaySection(pkgName,objName,title,props)


















    propsList=cell(1,numel(props));

    for i=1:numel(props)
        msgID=[pkgName,':',objName,':Prop',props{i}];
        propsList{i}=matlab.system.display.internal.Property(...
        props{i},'Description',getString(message(msgID)));
    end

    titleMsgID=[pkgName,':',objName,':Title',title];
    titleMsg=getString(message(titleMsgID));

    dispSection=matlab.system.display.Section('Title',titleMsg,'PropertyList',propsList);
end