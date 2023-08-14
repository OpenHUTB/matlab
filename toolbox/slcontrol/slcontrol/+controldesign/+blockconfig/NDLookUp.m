classdef NDLookUp<controldesign.blockconfig.GainSurface





    properties(Access=protected)

BreakPoints_

        GridFirst_=true;
    end

    methods(Access=public)

        function this=NDLookUp(BlockPath)

            if nargin==0
                return
            end
            this.BlockPath=BlockPath;

            [precompiled,ModelParameterMgr]=this.preprocessModel(getModelName(this));
            try
                feature('EngineInterface',Simulink.EngineInterfaceVal.byFiat)
                r=get_param(BlockPath,'RunTimeObject');

                ndim=r.NumInputPorts;
                this.NDIM_=ndim;

                p=RuntimePrm(r,1);
                this.SLMaskParameters_=struct('Name',p.Name,'Value',p.Data,'Tunable','on');

                initialize(this)

                bp=cell(1,ndim);
                for ct=1:ndim
                    p=RuntimePrm(r,ct+1);
                    bp{ct}=p.Data;
                end
                this.BreakPoints_=bp;

                this.postprocessModel(precompiled,ModelParameterMgr)
            catch ME
                this.postprocessModel(precompiled,ModelParameterMgr)
                throw(ME)
            end
        end

        function TC=getDefaultParameterization(this)


            TableData=this.SLMaskParameters_.Value;
            std=size(TableData);
            isel=num2cell(ceil(std/2));
            TC=tunableGain(this.Name,TableData(isel{:}));
            TC.Ts=this.Ts;
        end

        function TableData=readValueFromSLMaskParameters(this,~)
            TableData=this.SLMaskParameters_.Value;
        end

        function writeValueToSLMaskParameters(this,TableData)
            this.SLMaskParameters_.Value=TableData;
        end

        function writeParamToSLMaskParameters(this)


            TC=this.Parameterization;
            XLUT=this.BreakPoints_;
            if isa(TC,'tunableSurface')

                if this.GridFirst_
                    [this.SLMaskParameters_.Value,RangeFactor]=evalSurf(TC,XLUT{:});
                else
                    [this.SLMaskParameters_.Value,RangeFactor]=evalSurf(TC,XLUT{:},'gridlast');
                end
                if RangeFactor>1.5
                    warning(message('Slcontrol:controldesign:NDLookUp11',this.BlockPath))
                end
            else
                V=getValue(TC);
                if isa(V,'ss')
                    V=V.d;
                end
                if isa(TC,'ltipack.ModelArray')&&~isequal(TC.SamplingGrid,struct)


                    if nmodels(TC)==1



                        iLoc=localLocalize(TC,XLUT);
                        if isempty(iLoc)
                            warning(message('Slcontrol:controldesign:NDLookUp10',this.BlockPath))
                            return
                        end
                        if this.GridFirst_
                            this.SLMaskParameters_.Value(iLoc)=V;
                        else
                            this.SLMaskParameters_.Value(:,:,iLoc)=V;
                        end
                    else




                        GridInfo=ltipack.SamplingGrid.getGridStructure(TC.SamplingGrid);
                        X=cellfun(@(x)x{2},GridInfo.GridVectors,'UniformOutput',false);
                        if numel(X)~=this.NDIM_||any(cellfun(@numel,X)<2)

                            warning(message('Slcontrol:controldesign:NDLookUp9',this.BlockPath))
                            return
                        end
                        [X{:}]=ndgrid(X{:});
                        [XLUT{:}]=ndgrid(XLUT{:});
                        if this.GridFirst_
                            V=V(GridInfo.SamplePerm);
                            V=reshape(V,GridInfo.GridSize);
                            VLUT=interpn(X{:},V,XLUT{:});

                            ix=find(isfinite(VLUT));
                            this.SLMaskParameters_.Value(ix)=VLUT(ix);
                        else
                            ndims=this.NDIM_;ios=this.IOSize_;
                            V=reshape(V(:,:,GridInfo.SamplePerm),[ios,GridInfo.GridSize]);
                            V=permute(V,[3:2+ndims,1,2]);
                            cdims=repmat({':'},1,ndims);
                            nLUT=numel(XLUT{1});
                            VLUT=zeros([nLUT,ios]);
                            isFinite=true(nLUT,1);
                            for ct=1:ios(1)*ios(2)
                                aux=interpn(X{:},V(cdims{:},ct),XLUT{:});
                                VLUT(:,ct)=aux(:);
                                isFinite=isFinite&isfinite(aux(:));
                            end
                            VLUT=permute(VLUT,[2,3,1]);
                            ix=find(isFinite);
                            this.SLMaskParameters_.Value(:,:,ix)=VLUT(:,:,ix);

                        end
                    end
                else



                    if this.GridFirst_
                        this.SLMaskParameters_.Value(:)=V;
                    else
                        [~,~,npts]=size(this.SLMaskParameters_.Value);
                        this.SLMaskParameters_.Value(:,:,:)=repmat(V,[1,1,npts]);
                    end
                end
            end
        end

        function writeParamToLUTSection(this,varargin)

            TC=this.Parameterization;
            XLUT=this.BreakPoints_;


            ndim=this.NDIM_;
            std=size(this.SLMaskParameters_.Value);
            if~this.GridFirst_
                std=std(3:end);
            end
            if ndim==1
                std=[prod(std),1];
            end
            nidx=numel(varargin);
            if nidx==1&&ndim>1

                idx=varargin{1};
                if~(localIsIndexArray(idx)&&size(idx,2)==ndim)
                    error(message('Slcontrol:controldesign:NDLookUp13',ndim))
                elseif any(max(idx,[],1)>std)
                    error(message('Slcontrol:controldesign:NDLookUp14',find(max(idx,[],1)>std,1)))
                end

                aux=num2cell(idx,1);
                varargin{1}=sub2ind(std,aux{:});
            else

                if nidx~=ndim
                    error(message('Slcontrol:controldesign:NDLookUp15',ndim))
                else
                    for ct=1:ndim
                        idx=varargin{ct};
                        if~(isvector(idx)&&localIsIndexArray(idx))
                            error(message('Slcontrol:controldesign:NDLookUp16',ct))
                        elseif max(idx)>std(ct)
                            error(message('Slcontrol:controldesign:NDLookUp14',ct))
                        end
                    end
                end
            end


            if isa(TC,'tunableSurface')
                if nidx==ndim

                    for ct=1:ndim
                        XLUT{ct}=XLUT{ct}(varargin{ct});
                    end
                else


                    [XLUT{:}]=ndgrid(XLUT{:});
                    for ct=1:ndim
                        XLUT{ct}=XLUT{ct}(varargin{1});
                    end
                    XLUT={cat(2,XLUT{:})};
                end
                if this.GridFirst_
                    [this.SLMaskParameters_.Value(varargin{:}),RangeFactor]=evalSurf(TC,XLUT{:});
                else
                    [this.SLMaskParameters_.Value(:,:,varargin{:}),RangeFactor]=evalSurf(TC,XLUT{:},'gridlast');
                end
                if RangeFactor>1.5
                    warning(message('Slcontrol:controldesign:NDLookUp11',this.BlockPath))
                end
            else
                V=getValue(TC);
                if isa(V,'ss')
                    V=V.d;
                end
                if isa(TC,'ltipack.ModelArray')&&~isequal(TC.SamplingGrid,struct)


                    if nmodels(TC)==1



                        iLoc=localLocalize(TC,XLUT);
                        if isempty(iLoc)
                            warning(message('Slcontrol:controldesign:NDLookUp10',this.BlockPath))
                            return
                        end

                        isSelected=true;
                        if nidx==ndim
                            idx=cell(1,ndim);
                            [idx{:}]=ind2sub(std,iLoc);
                            for ct=1:ndim
                                if~ismember(idx{ct},varargin{ct})
                                    isSelected=false;break
                                end
                            end
                        else
                            isSelected=ismember(iLoc,varargin{1});
                        end
                        if isSelected
                            if this.GridFirst_
                                this.SLMaskParameters_.Value(iLoc)=V;
                            else
                                this.SLMaskParameters_.Value(:,:,iLoc)=V;
                            end
                        end
                    else




                        GridInfo=ltipack.SamplingGrid.getGridStructure(TC.SamplingGrid);
                        X=cellfun(@(x)x{2},GridInfo.GridVectors,'UniformOutput',false);
                        if numel(X)~=this.NDIM_||any(cellfun(@numel,X)<2)

                            warning(message('Slcontrol:controldesign:NDLookUp9',this.BlockPath))
                            return
                        end
                        if nidx==ndim

                            for ct=1:ndim
                                XLUT{ct}=XLUT{ct}(varargin{ct});
                            end
                            [XLUT{:}]=ndgrid(XLUT{:});
                            [varargin{:}]=ndgrid(varargin{:});
                            kabs=sub2ind(std,varargin{:});
                        else

                            kabs=varargin{1};
                            [XLUT{:}]=ndgrid(XLUT{:});
                            for ct=1:ndim
                                XLUT{ct}=XLUT{ct}(kabs);
                            end
                        end
                        [X{:}]=ndgrid(X{:});
                        if this.GridFirst_
                            V=V(GridInfo.SamplePerm);
                            V=reshape(V,GridInfo.GridSize);
                            VLUT=interpn(X{:},V,XLUT{:});

                            ix=find(isfinite(VLUT));
                            this.SLMaskParameters_.Value(kabs(ix))=VLUT(ix);
                        else
                            ndims=this.NDIM_;
                            ios=this.IOSize_;
                            V=reshape(V(:,:,GridInfo.SamplePerm),[ios,GridInfo.GridSize]);
                            V=permute(V,[3:2+ndims,1,2]);
                            cdims=repmat({':'},1,ndims);
                            nLUT=numel(XLUT{1});
                            VLUT=zeros([nLUT,ios]);
                            isFinite=true(nLUT,1);
                            for ct=1:ios(1)*ios(2)
                                aux=interpn(X{:},V(cdims{:},ct),XLUT{:});
                                VLUT(:,ct)=aux(:);
                                isFinite=isFinite&isfinite(aux(:));
                            end
                            VLUT=permute(VLUT,[2,3,1]);
                            ix=find(isFinite);
                            this.SLMaskParameters_.Value(:,:,kabs(ix))=VLUT(:,:,ix);
                        end
                    end
                else



                    if this.GridFirst_
                        this.SLMaskParameters_.Value(varargin{:})=V;
                    else
                        if ndim>1&&nidx==ndim
                            [varargin{:}]=ndgrid(varargin{:});
                            kabs=sub2ind(std,varargin{:});
                        else
                            kabs=varargin{1};
                        end
                        this.SLMaskParameters_.Value(:,:,kabs)=repmat(V,[1,1,numel(kabs)]);
                    end
                end
            end
        end

    end



end



function iabs=localLocalize(TC,GV)

    GridSize=cellfun(@numel,GV);
    ndim=numel(GridSize);
    iabs=[];
    try %#ok<TRYNC>

        PointData=struct2cell(TC.SamplingGrid);
        if numel(PointData)==ndim
            subs=cell(1,ndim);
            for ct=1:ndim
                i=find(GV{ct}==PointData{ct});
                if isempty(i)
                    return
                else
                    subs{ct}=i;
                end
            end
            iabs=sub2ind([GridSize,1],subs{:});
        end
    end
end


function pf=localIsIndexArray(A)

    A=A(:);
    pf=isnumeric(A)&&isreal(A)&&ismatrix(A)&&...
    all(A==round(A)&A>0&isfinite(A));
end