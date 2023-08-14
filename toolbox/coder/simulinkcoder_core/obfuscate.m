function obfuscate(varargin)
























    workingDir='.';
    outputDir='.';
    mdlName='';
    ofcLevel=0;
    noConstantHeader=false;


    inputLen=length(varargin);
    if inputLen>5
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    elseif(inputLen==5)
        workingDir=varargin{1};
        outputDir=varargin{2};
        mdlName=varargin{3};
        ofcLevel=varargin{4};
        noConstantHeader=varargin{5};
    elseif(inputLen==4)
        workingDir=varargin{1};
        outputDir=varargin{2};
        mdlName=varargin{3};
        ofcLevel=varargin{4};
    elseif(inputLen==3)
        workingDir=varargin{1};
        outputDir=varargin{2};
        mdlName=varargin{3};
    elseif(inputLen==2)
        workingDir=varargin{1};
        outputDir=varargin{2};
    elseif(inputLen==1)
        workingDir=varargin{1};
    end



    if~(~strcmp(workingDir,'')&&ischar(workingDir)&&exist(workingDir,'file'))
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    end


    if~(~strcmp(outputDir,'')&&ischar(outputDir))
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    end


    if~(ischar(mdlName))
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    end


    if ischar(ofcLevel)||(ofcLevel>2||ofcLevel<0)
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    end


    if~islogical(noConstantHeader)
        DAStudio.error('Simulink:utility:invalidInputArgs','Obfuscate');
    end

    ofc(workingDir,outputDir,mdlName,ofcLevel,noConstantHeader);

