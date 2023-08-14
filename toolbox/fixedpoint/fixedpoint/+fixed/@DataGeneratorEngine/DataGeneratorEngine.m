classdef(Hidden)DataGeneratorEngine<matlab.System



















































    properties(Nontunable)


        DataSpecifications={fixed.DataSpecification('double')};


        NumDataPointsLimit=100e3;
    end

    properties(Nontunable,SetAccess=private,GetAccess=...
        {?fixed.DataGeneratorEngine,?matlab.unittest.TestCase})
NumDataSpecs
ValueSetSizes
CPSize
ValueSets
CPSections
CPBases
CPFold
    end

    properties(SetAccess=private,GetAccess=...
        {?fixed.DataGeneratorEngine,?matlab.unittest.TestCase})
Assemblers
CPIndices
OutBuf
        IsDone=false
    end

    methods

        function obj=DataGeneratorEngine(varargin)









            setProperties(obj,nargin,varargin{:});
        end


        function set.DataSpecifications(obj,val)
            if~iscell(val)
                val={val};
            end
            validateattributes(val,{'cell'},{'nonempty'});
            for i=1:numel(val)
                validateattributes(val{i},{'fixed.DataSpecificationInterface'},{'scalar'},"","DataSpecifications{"+i+"}");
                validateProperties(val{i},"DataSpecifications{"+i+"}");
            end
            obj.DataSpecifications=val(:)';
        end

        function set.NumDataPointsLimit(obj,val)
            validateattributes(val,{'numeric'},{'scalar','real','positive'});
            limit=double(val);
            if~isinf(limit)
                validateattributes(val,{'numeric'},{'integer'});
                if limit>val
                    limit=fixed.internal.math.prevFiniteRepresentable(limit);
                end
            end
            obj.NumDataPointsLimit=limit;
        end


        function info=getNumDataPointsInfo(obj)













            narginchk(1,1);
            validateattributes(obj,{'fixed.DataGeneratorEngine'},{'scalar'},1);

            [~,cpsz,cpszmin,cpszmax]=obj.propagateSpecifications(...
            obj.DataSpecifications,obj.NumDataPointsLimit,false);
            [~,cpsznext,~,~]=obj.propagateSpecifications(...
            obj.DataSpecifications,cpsz+1,true);

            if cpszmax>2^53
                warning(message("fixed:datagen:impreciseCPSizeInfo"));
            end
            info=struct(...
            'Current',cpsz,...
            'Next',cpsznext,...
            'Min',cpszmin,...
            'Max',cpszmax);
        end
    end


    methods(Access=protected)
        function validatePropertiesImpl(obj)




            coder.extrinsic('propagateSpecifications');
            obj.NumDataSpecs=numel(obj.DataSpecifications);
            [vssz,cpsz,cpszmin]=coder.const(...
            @obj.propagateSpecifications,obj.DataSpecifications,obj.NumDataPointsLimit,false);

            if obj.NumDataPointsLimit>0&&obj.NumDataPointsLimit<cpszmin
                throwAsCaller(MException(...
                message("fixed:datagen:expectedCPSizeLimNoLessThanMin",string(cpszmin))));
            end

            obj.ValueSetSizes=vssz;
            obj.CPSize=cpsz;
        end

        function releaseImpl(obj)






            obj.resetImpl;
        end

        function setupImpl(obj)




            coder.extrinsic('populateCartesianProductSettings');
            [obj.ValueSets,obj.CPSections,obj.CPBases,obj.CPFold]=coder.const(...
            @obj.populateCartesianProductSettings,obj.DataSpecifications,obj.ValueSetSizes);
            for i=1:obj.NumDataSpecs
                obj.Assemblers{i}=getUnitAssembler(obj.DataSpecifications{i});
            end
        end

        function resetImpl(obj)




            obj.CPIndices=ones([1,obj.CPFold],'int32');
            for i=1:obj.NumDataSpecs
                obj.OutBuf{i}=obj.Assemblers{i}(obj.ValueSets{i}(obj.CPIndices(obj.CPSections{i})));
            end
            obj.IsDone=false;
        end

        function stepImpl(obj)





            i=1;
            while i<=obj.CPFold&&obj.CPIndices(i)==obj.CPBases(i)
                obj.CPIndices(i)=1;
                i=i+1;
            end


            if i<=obj.CPFold
                obj.CPIndices(i)=obj.CPIndices(i)+1;
            else
                obj.IsDone=true;
            end


            j=1;
            while j<=obj.NumDataSpecs&&obj.CPSections{j}(1)<=i


                obj.OutBuf{j}=obj.Assemblers{j}(obj.ValueSets{j}(obj.CPIndices(obj.CPSections{j})));
                j=j+1;
            end
        end
    end

    methods(Static,Hidden)
        function[vssz,cpsz,cpszmin,cpszmax]=propagateSpecifications(ds,cpszdsr,useright)

















            [vsszreq,vsszmin,vsszmax]=cellfun(@(x)getValueSetSizeInfo(x),ds);
            dof=cellfun(@(x)getDegreesOfFreedom(x),ds);
            isset=vsszreq>0;
            isvar=~isset;


            cpszset=fcpsz(vsszreq(isset),dof(isset));
            cpszmin=cpszset*fcpsz(vsszmin(isvar),dof(isvar));
            cpszmax=cpszset*fcpsz(vsszmax(isvar),dof(isvar));






            vssz=vsszreq;
            if any(isvar)
                if cpszdsr>=cpszmax
                    vssz(isvar)=vsszmax(isvar);
                elseif cpszdsr<=cpszmin
                    vssz(isvar)=vsszmin(isvar);
                else
                    fvssz=@(x)vsszmin(isvar)+int32(round(double(vsszmax(isvar)-vsszmin(isvar))*x));
                    if useright
                        [xt,~,xa]=fixed.internal.utility.searchsolve(...
                        @(x)fcpsz(fvssz(x),dof(isvar)),ceil(cpszdsr/cpszset),[0,1]);
                    else
                        [xt,xa,~]=fixed.internal.utility.searchsolve(...
                        @(x)fcpsz(fvssz(x),dof(isvar)),floor(cpszdsr/cpszset),[0,1]);
                    end
                    vssz(isvar)=fvssz([xt,xa]);
                end
            end
            cpsz=cpszset*fcpsz(vssz(isvar),dof(isvar));
        end

        function[valueSets,cpSections,cpBases,cpFold]=populateCartesianProductSettings(ds,vssz)


            nds=numel(ds);
            valueSets=cell(1,nds);
            cpSections=cell(1,nds);
            cpBases=cell(1,nds);
            cpFold=0;
            for i=1:nds
                dof=getDegreesOfFreedom(ds{i});
                valueSets{i}=getValueSet(ds{i},vssz(i));
                cpSections{i}=cpFold+(1:dof);
                cpBases{i}=repmat(vssz(i),[1,dof]);
                cpFold=cpSections{i}(end);
            end
            cpBases=cell2mat(cpBases);
        end
    end
end


function cpsz=fcpsz(vssz,dof)


    cpsz=prod(double(vssz).^double(dof));
end
