classdef ObjectArrayCG<coder.mixin.internal.indexing.Paren %#codegen




    properties(Access={?satelliteScenario,?matlabshared.satellitescenario.coder.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.Access,...
        ?satcom.satellitescenario.internal.Link,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.Access,...
        ?satcom.satellitescenario.Link})
Handles
    end

    methods
        function asset=cat(~,varargin)


            coder.allowpcode('plain');




            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','cat');
        end

        function asset=ctranspose(asset)


            coder.allowpcode('plain');




            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','cat');
        end

        function e=end(asset,k,n)


            coder.allowpcode('plain');

            s=size(asset.Handles);
            nds=numel(s);
            s=[s,ones(1,n-length(s)+1)];
            if n==1&&k==1
                e=prod(s);
            elseif n==nds||k<n
                e=s(k);
            else
                e=prod(s(k:end));
            end
        end

        function tf=eq(asset1,asset2)


            coder.allowpcode('plain');

            tf=true;

            if~strcmpi(class(asset1),class(asset2))
                tf=false;
                return
            end

            if size(asset1.Handles)~=size(asset2.Handles)
                tf=false;
                return
            end

            for idx=1:numel(asset1.Handles)
                if~isequal(asset1.Handles{idx},asset2.Handles{idx})
                    tf=false;
                    return
                end
            end
        end

        function asset=horzcat(assetIn,varargin)


            coder.allowpcode('plain');


            switch class(assetIn)
            case 'matlabshared.satellitescenario.Satellite'
                asset=matlabshared.satellitescenario.Satellite;
            case 'matlabshared.satellitescenario.GroundStation'
                asset=matlabshared.satellitescenario.GroundStation;
            case 'matlabshared.satellitescenario.Gimbal'
                asset=matlabshared.satellitescenario.Gimbal;
            case 'matlabshared.satellitescenario.ConicalSensor'
                asset=matlabshared.satellitescenario.ConicalSensor;
            case 'matlabshared.satellitescenario.Access'
                asset=matlabshared.satellitescenario.Access;
            case 'satcom.satellitescenario.Transmitter'
                asset=satcom.satellitescenario.Transmitter;
            case 'satcom.satellitescenario.Receiver'
                asset=satcom.satellitescenario.Receiver;
            otherwise
                asset=satcom.satellitescenario.Link;
            end
            handles=assetIn.Handles;


            s=size(handles);

            if numel(s)>2||s(1)~=1

                coder.internal.error('shared_orbit:orbitPropagator:OnlyRowVectorsSupportedForCodegen');
            end


            numGs=numel(assetIn.Handles);


            for idx=1:numel(varargin)

                s=size(varargin{idx});

                if numel(s)>2||s(1)~=1


                    coder.internal.error('shared_orbit:orbitPropagator:OnlyRowVectorsSupportedForCodegen');
                end



                if~strcmpi(class(assetIn),class(varargin{idx}))
                    coder.internal.error('shared_orbit:orbitPropagator:CatArraysDifferent',class(assetIn));
                end



                numGs=numGs+numel(varargin{idx}.Handles);
            end


            handles=coder.nullcopy(cell(1,numGs));


            for idx=1:numel(assetIn.Handles)
                handles{idx}=assetIn.Handles{idx};
            end


            count=numel(assetIn.Handles);
            for idx1=1:numel(varargin)
                for idx2=1:numel(varargin{idx1}.Handles)
                    handles{count+idx2}=varargin{idx1}.Handles{idx2};
                end
                count=count+numel(varargin{idx1}.Handles);
            end


            asset.Handles=handles;
        end

        function tf=iscolumn(asset)


            coder.allowpcode('plain');

            tf=iscolumn(asset.Handles);
        end

        function tf=isempty(asset)


            coder.allowpcode('plain');

            tf=isempty(asset.Handles);
        end

        function tf=ismatrix(asset)


            coder.allowpcode('plain');

            tf=ismatrix(asset.Handles);
        end

        function tf=isrow(asset)


            coder.allowpcode('plain');

            tf=isrow(asset.Handles);
        end

        function tf=isscalar(asset)


            coder.allowpcode('plain');

            tf=isscalar(asset.Handles);
        end

        function tf=isvalid(~)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','isvalid');
        end

        function tf=isvector(asset)


            coder.allowpcode('plain');

            tf=isvector(asset.Handles);
        end

        function l=length(asset)


            coder.allowpcode('plain');

            l=length(asset.Handles);
        end

        function n=numel(asset)


            coder.allowpcode('plain');

            n=numel(asset.Handles);
        end

        function asset=parenAssign(asset,rhs,varargin)


            coder.allowpcode('plain');

            if isempty(rhs)

                coder.internal.error('shared_orbit:orbitPropagator:ParenDeleteNotSupportedForCodegen');
            else
                if isa(asset,'double')&&isempty(asset)&&numel(rhs.Handles)==1

                    asset=matlabshared.satellitescenario.GroundStation;
                end



                asset.Handles{varargin{:}}=rhs.Handles{:};
            end
        end

        function asset=parenDelete(asset,varargin)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:ParenDeleteNotSupportedForCodegen');
        end

        function asset=parenReference(asset,varargin)


            coder.allowpcode('plain');

            asset.Handles={asset.Handles{varargin{:}}};
        end

        function asset=permute(asset,~)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','permute');
        end

        function asset=repmat(asset,varargin)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','repmat');
        end

        function asset=reshape(asset,varargin)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','reshape');
        end

        function varargout=size(asset,varargin)


            coder.allowpcode('plain');

            [varargout{1:nargout}]=size(asset.Handles,varargin{:});
        end

        function asset=transpose(asset)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','transpose');
        end

        function asset=vertcat(asset,varargin)


            coder.allowpcode('plain');

            coder.internal.errorIf(true,'shared_orbit:orbitPropagator:UnsupportedArrayOperation','vertcat');
        end
    end
end

