function out=channelList(obj,varargin)



























    p=inputParser;
    p.addOptional('channelName',"",@(x)validateattributes(x,{'char','string'},{'nonempty','row'},'channelList','CHANNELNAME'));
    p.addParameter('ExactMatch',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    p.parse(varargin{:});


    channelName=string(p.Results.channelName);
    nameStrings=cellfun(@string,obj.ChannelNames,'UniformOutput',false);



    if p.Results.ExactMatch

        matches=cellfun(@(x)x==channelName,nameStrings,'UniformOutput',false);
    else

        matches=cellfun(@(x)contains(x,channelName,'IgnoreCase',true),nameStrings,'UniformOutput',false);
    end


    numMatches=sum(arrayfun(@(x)sum(x{1}),matches));


    varChName=cell(1,numMatches);
    varChGrpNum=zeros(1,numMatches);
    varChGrpNumSamples=zeros(1,numMatches,'uint64');
    varChGrpAcqName=cell(1,numMatches);
    varChGrpComment=cell(1,numMatches);
    varChGrpSrcInfo=struct('Name',cell(1,numMatches),'Path',cell(1,numMatches),'Comment',cell(1,numMatches),...
    'SourceType',cell(1,numMatches),'BusType',cell(1,numMatches),'BusChannelNumber',cell(1,numMatches),'Simulated',cell(1,numMatches));
    varChDisplayName=cell(1,numMatches);
    varChExtNamePrefix=cell(1,numMatches);
    varChType=asam.mdf.ChannelType(zeros(1,numMatches));
    varChDataType=asam.mdf.ChannelDataType(zeros(1,numMatches));
    varChNumBits=zeros(1,numMatches);
    varChComponentType=asam.mdf.ChannelComponentType(zeros(1,numMatches));
    varChCompositionType=asam.mdf.ChannelCompositionType(zeros(1,numMatches));
    varChConverstionType=asam.mdf.ChannelConversionType(zeros(1,numMatches));
    varChUnit=cell(1,numMatches);
    varChComment=cell(1,numMatches);
    varChDescription=cell(1,numMatches);
    varChSrcInfo=struct('Name',cell(1,numMatches),'Path',cell(1,numMatches),'Comment',cell(1,numMatches),...
    'SourceType',cell(1,numMatches),'BusType',cell(1,numMatches),'BusChannelNumber',cell(1,numMatches),'Simulated',cell(1,numMatches));


    idx=1;
    for ii=1:numel(matches)

        for jj=1:numel(matches{ii})

            if matches{ii}(jj)

                varChName{idx}=obj.ChannelNames{ii}{jj};
                varChGrpNum(idx)=ii;
                varChGrpNumSamples(idx)=obj.ChannelGroup(ii).NumSamples;
                varChGrpAcqName{idx}=obj.ChannelGroup(ii).AcquisitionName;
                varChGrpComment{idx}=obj.ChannelGroup(ii).Comment;
                varChGrpSrcInfo(idx)=obj.ChannelGroup(ii).SourceInfo;
                varChGrpSrcInfo(idx).Name=string(varChGrpSrcInfo(idx).Name);
                varChGrpSrcInfo(idx).Path=string(varChGrpSrcInfo(idx).Path);
                varChGrpSrcInfo(idx).Comment=string(varChGrpSrcInfo(idx).Comment);
                varChDisplayName{idx}=obj.ChannelGroup(ii).Channel(jj).DisplayName;
                varChExtNamePrefix{idx}=obj.ChannelGroup(ii).Channel(jj).ExtendedNamePrefix;
                varChType(idx)=obj.ChannelGroup(ii).Channel(jj).Type;
                varChDataType(idx)=obj.ChannelGroup(ii).Channel(jj).DataType;
                varChNumBits(idx)=obj.ChannelGroup(ii).Channel(jj).NumBits;
                varChComponentType(idx)=obj.ChannelGroup(ii).Channel(jj).ComponentType;
                varChCompositionType(idx)=obj.ChannelGroup(ii).Channel(jj).CompositionType;
                varChConverstionType(idx)=obj.ChannelGroup(ii).Channel(jj).ConversionType;
                varChUnit{idx}=obj.ChannelGroup(ii).Channel(jj).Unit;
                varChComment{idx}=obj.ChannelGroup(ii).Channel(jj).Comment;
                varChDescription{idx}=obj.ChannelGroup(ii).Channel(jj).Description;
                varChSrcInfo(idx)=obj.ChannelGroup(ii).Channel(jj).SourceInfo;
                varChSrcInfo(idx).Name=string(varChSrcInfo(idx).Name);
                varChSrcInfo(idx).Path=string(varChSrcInfo(idx).Path);
                varChSrcInfo(idx).Comment=string(varChSrcInfo(idx).Comment);
                idx=idx+1;
            end
        end
    end




    varChName=string(varChName)';
    varChGrpAcqName=string(varChGrpAcqName)';
    varChGrpComment=string(varChGrpComment)';
    varChDisplayName=string(varChDisplayName)';
    varChExtNamePrefix=string(varChExtNamePrefix)';
    varChUnit=string(varChUnit)';
    varChComment=string(varChComment)';
    varChDescription=string(varChDescription)';


    varChGrpNum=varChGrpNum';
    varChGrpNumSamples=varChGrpNumSamples';
    varChGrpSrcInfo=varChGrpSrcInfo';
    varChType=varChType';
    varChConverstionType=varChConverstionType';
    varChDataType=varChDataType';
    varChNumBits=varChNumBits';
    varChComponentType=varChComponentType';
    varChCompositionType=varChCompositionType';
    varChSrcInfo=varChSrcInfo';



    out=table(varChName,varChGrpNum,varChGrpNumSamples,varChGrpAcqName,varChGrpComment,varChGrpSrcInfo,varChDisplayName,...
    varChUnit,varChComment,varChDescription,varChExtNamePrefix,varChType,varChDataType,varChNumBits,varChComponentType,varChCompositionType,varChConverstionType,varChSrcInfo,...
    'VariableNames',{'ChannelName','ChannelGroupNumber','ChannelGroupNumSamples',...
    'ChannelGroupAcquisitionName','ChannelGroupComment','ChannelGroupSourceInfo','ChannelDisplayName','ChannelUnit','ChannelComment'...
    ,'ChannelDescription','ChannelExtendedNamePrefix','ChannelType','ChannelDataType','ChannelNumBits','ChannelComponentType','ChannelCompositionType','ChannelConversionType','ChannelSourceInfo'});


    out.ChannelGroupAcquisitionName=categorical(out.ChannelGroupAcquisitionName);
    out.ChannelGroupComment=categorical(out.ChannelGroupComment);
    out.ChannelComment=categorical(out.ChannelComment);
    out.ChannelUnit=categorical(out.ChannelUnit);
    out.ChannelExtendedNamePrefix=categorical(out.ChannelExtendedNamePrefix);


    if~isempty(out)
        [~,order]=sort(out.ChannelName.lower);
        out=out(order,:);
    end
end
