classdef dlAccel_info







    properties(SetAccess=private)


        inputType char='single'
        inputSize{mustBePositive,mustBeInteger}
        activationLayerName=[]


        miniBatchSize{mustBePositive,mustBeInteger}=128

        targetLib char='cudnn'


        dlAccelDir char
        mexFunctionName char
        mTemplateName char
        checksum=[]
    end

    methods
        function obj=dlAccel_info(buildDir,dataSize,precision,miniBatchSize,targetLib,activationLayerName)

            uniqueStr=strrep(tempname,tempdir,'');

            if isempty(activationLayerName)
                obj.mexFunctionName=[uniqueStr,'_pred_mex'];
                obj.mTemplateName='mDlAccel_pred';
            else
                obj.mexFunctionName=[uniqueStr,'_act_mex'];
                obj.mTemplateName='mDlAccel_act';
            end
            obj.dlAccelDir=buildDir;
            obj.targetLib=targetLib;
            obj.inputType=precision;
            obj.miniBatchSize=miniBatchSize;
            obj.activationLayerName=activationLayerName;
            obj.inputSize=dataSize;
        end

        function varargout=invoke(this,varargin)


            try
                [varargout{1:nargout}]=feval(this.mexFunctionName,varargin{:});
            catch err



                clear(this.mexFunctionName);


                e=MException(message('nnet_cnn:dlAccel:MEXCallFailed'));
                e=addCause(e,err);
                throw(e)
            end
        end

        function delete(this)



            clear(this.mexFunctionName);


            mexFile=fullfile(this.dlAccelDir,[this.mexFunctionName,'.',mexext]);
            if exist(mexFile,'file')
                delete(mexFile);
            end
            iRmDirNoError(fullfile(this.dlAccelDir,this.mexFunctionName));
        end

        function this=setChecksum(this)

            this.checksum=computeChecksum(this);
        end

        function status=isValid(this)


            [chksum,mexExist]=computeChecksum(this);
            status=isequal(this.checksum,chksum)&&mexExist;
        end

    end

end


function[chksum,mexExist]=computeChecksum(this)





    mexFile=fullfile(this.dlAccelDir,[this.mexFunctionName,'.',mexext]);
    if exist(mexFile,'file')
        mexInfo=dir(mexFile);
        mexStamp=mexInfo.datenum;
        mexExist=true;
    else
        mexStamp=[];
        mexExist=false;
    end


    dataFiles=dir(fullfile(this.dlAccelDir,this.mexFunctionName,'cnn*'));
    dataStamps=ones(numel(dataFiles),1);
    for k=1:length(dataStamps)
        dataStamps(k)=dataFiles(k).datenum;
    end


    chksum=[mexStamp;dataStamps];

end

function iRmDirNoError(dir)
    try
        rmdir(dir,'s');
    catch ME
        if ME.identifier~="MATLAB:RMDIR:NotADirectory"
            rethrow(ME);
        end
    end
end


