function generateRTMX(topArtifactInfo,leftArtifactInfo,inputOptions)






















    if nargin<1||(isempty(topArtifactInfo)&&isempty(leftArtifactInfo))
        slreq.report.rtmx.utils.MatrixWindow.showMatrixWindow();
        return;
    end

    if nargin>0

        if iscell(topArtifactInfo)
            if nargin==1
                if size(topArtifactInfo)>2

                    error('Currently, only support at most two artifact at same time');
                end

                topArtifactInfo=topArtifactInfo(1);
                if length(topArtifactInfo)==1
                    leftArtifactInfo={};
                else
                    leftArtifactInfo=topArtifactInfo(2);
                end
                inputOptions=struct;
            end

            if nargin==2
                if~iscell(leftArtifactInfo)
                    inputOptions=leftArtifactInfo;

                    if length(topArtifactInfo)>2

                        error('Currently, only support at most two artifact at same time');
                    end


                    if length(topArtifactInfo)==1
                        leftArtifactInfo={};
                    else
                        leftArtifactInfo=topArtifactInfo(2);
                    end
                    topArtifactInfo=topArtifactInfo(1);

                    if isempty(leftArtifactInfo)
                        exporter=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance;
                        leftArtifactInfo=exporter.getDstArtifactFromSource(topArtifactInfo);
                    end
                else
                    inputOptions=struct;
                end
            end
        else

            error('does not support this input type, either cell of file paths or a array of slreq.report.rtmx.utils.MatrixArtifact');
        end
    end

    options.showArtifactSelector=false;
    options.queryOtherDataInMemory=false;
    options.configurationFile='';
    if isfield(inputOptions,'showArtifactSelector')
        options.showArtifactSelector=inputOptions.showArtifactSelector;
    elseif isfield(inputOptions,'promptToUsers')
        options.showArtifactSelector=inputOptions.promptToUsers;
    end


    if isfield(inputOptions,'queryOtherDataInMemory')
        options.queryOtherDataInMemory=inputOptions.queryOtherDataInMemory;
    end

    if isfield(inputOptions,'configurationFile')
        options.configurationFile=inputOptions.configurationFile;
    end

    if isfield(inputOptions,'options')
        options.configurationData=inputOptions.options;
    end

    slreq.report.rtmx.utils.MatrixWindow.showMatrixWindow(topArtifactInfo,leftArtifactInfo,options);
end

