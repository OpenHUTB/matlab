classdef GroupNormalizationLayer<nnet.layer.Layer

%#codegen

    properties
NumGroups
Scale
Offset
Epsilon
ChannelDim
NumChannels
    end


    methods

        function layer=GroupNormalizationLayer(numGroups,scale,offset,epsilon,name)
            coder.allowpcode('plain');

            layer.NumGroups=numGroups;
            layer.Scale=scale;
            layer.Offset=offset;
            layer.Epsilon=epsilon;
            layer.Name=name;

            szLearnable=size(scale);
            if isempty(szLearnable)
                error('At codegen time, learnables must be nonempty')
            elseif szLearnable(1)~=1
                layer.ChannelDim=1;
                layer.NumChannels=szLearnable(1);
            else
                layer.ChannelDim=length(szLearnable);
                layer.NumChannels=szLearnable(end);
            end
        end


        function Z=predict(this,X)
            inputdataIsDlarray=isa(X,'dlarray');
            if inputdataIsDlarray
                dlXdims=dims(X);
                Xnum=extractdata(X);
            else
                Xnum=X;
            end

            channelDim=this.ChannelDim;
            G=this.NumGroups;
            epsilon=this.Epsilon;

            origSzX=size(Xnum);
            C=size(Xnum,channelDim);
            N=size(Xnum,channelDim+1);

            gamma=this.Scale;
            beta=this.Offset;

            dimsX=ndims(Xnum);
            batchDim=channelDim+1;
            numChannelsPerGroup=C/G;
            needsPermute=(batchDim<dimsX);

            if needsPermute
                indexPermute=[batchDim+1:dimsX,1:channelDim-1,channelDim,batchDim];
                Xnum=permute(Xnum,indexPermute);
                permSzX=origSzX([indexPermute]);
                newSzX=[permSzX(1:end-2),numChannelsPerGroup,G,N];
                reduceDims=1:length(permSzX)-1;
            else
                newSzX=[origSzX(1:channelDim-1),numChannelsPerGroup,G,N];

                reduceDims=1:channelDim;
            end

            Xnum=reshape(Xnum,newSzX);

            m=numel(Xnum)./(G*N);
            groupMean=sum(Xnum,reduceDims)./m;
            groupVar=sum((bsxfun(@minus,Xnum,groupMean)).^2,reduceDims)./m;
            expandDim=ones([ones(1,ndims(Xnum)-3),numChannelsPerGroup,1,1]);
            newSzStats=[ones(1,channelDim-1),C,N,ones(1,dimsX-batchDim)];
            factorMean=bsxfun(@times,groupMean,expandDim);
            factorVar=bsxfun(@times,groupVar,expandDim);
            groupMean=reshape(factorMean,newSzStats);
            groupVar=reshape(factorVar,newSzStats);

            if needsPermute
                Xnum=reshape(Xnum,permSzX);
                Xnum=ipermute(Xnum,indexPermute);
            else
                Xnum=reshape(Xnum,origSzX);
            end

            invSqrtVarPlusEps=1./sqrt(groupVar+epsilon);
            scale=bsxfun(@times,gamma,invSqrtVarPlusEps);
            offset=bsxfun(@minus,beta,bsxfun(@times,groupMean,scale));
            Znum=bsxfun(@plus,bsxfun(@times,scale,Xnum),offset);

            if inputdataIsDlarray
                Z=dlarray(Znum,dlXdims);
            else
                Z=Znum;
            end
        end

    end


    methods(Static)

        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.layer.GroupNormalizationLayer(mlObj.NumGroups,...
            mlObj.Scale,mlObj.Offset,mlObj.Epsilon,mlObj.Name);
        end


        function mlObj=matlabCodegenFromRedirected(cgObj)
            mlObj=groupNormalizationLayer(cgObj.NumGroups,"Name",cgObj.Name,...
            "Offset",cgObj.Offset,"Scale",cgObj.Scale,"Epsilon",cgObj.Epsilon);
        end
    end
end
