function parseBuildParam(h,varargin)





    p=inputParser;
    p.addParamValue('QuestionDialog','off',...
    @(x)any(strcmpi(x,{'on','off'})));
    p.addParamValue('ContinueOnWarning','off',...
    @(x)any(strcmpi(x,{'on','off'})));
    p.addParamValue('BuildOutput','AllSL',...
    @(x)any(strcmpi(x,{'All','AllSL','AllML','HDLFilesOnly','FPGAFilesOnly',...
    'SLBlockOnly','MLSysObjOnly','MATFileOnly'})));
    p.addParamValue('MLSysObjClassName','');
    p.addParamValue('HDLCoderMode','off',...
    @(x)any(strcmpi(x,{'on','off'})));

    firstProcess={'ProjectGeneration','HDLCompilation',...
    'Synthesis','PlaceAndRoute','BitGeneration'};
    p.addParamValue('FirstFPGAProcess','HDLCompilation',...
    @(x)any(strcmpi(x,firstProcess)));

    finalProcess={'None','HDLCompilation',...
    'Synthesis','PlaceAndRoute','BitGeneration'};
    p.addParamValue('FinalFPGAProcess','BitGeneration',...
    @(x)any(strcmpi(x,finalProcess)));


    processCmd={'','HDLCompilation','Synthesis',...
    'PlaceAndRoute','BitGeneration'};
    processName={'','HDL compilation','synthesis',...
    'place and route','programming file generation'};

    if nargin>1
        p.parse(varargin{:});
        h.BuildOpt.QuestDlg=strcmpi(p.Results.QuestionDialog,'on');
        h.BuildOpt.NoWarn=strcmpi(p.Results.ContinueOnWarning,'on');
        h.BuildOpt.HDLCoderMode=strcmpi(p.Results.HDLCoderMode,'on');


        h.BuildOpt.GenHDL=any(strcmpi(p.Results.BuildOutput,...
        {'All','AllSL','AllML','HDLFilesOnly','FPGAFilesOnly'}));
        h.BuildOpt.GenFPGA=any(strcmpi(p.Results.BuildOutput,...
        {'All','AllSL','AllML','FPGAFilesOnly'}));
        h.BuildOpt.GenSLBlock=any(strcmpi(p.Results.BuildOutput,...
        {'All','AllSL','SLBlockOnly'}));
        h.BuildOpt.GenMLSysObj=any(strcmpi(p.Results.BuildOutput,...
        {'All','AllML','MLSysObjOnly'}));
        h.BuildOpt.GenMATFile=any(strcmpi(p.Results.BuildOutput,...
        {'All','AllSL','AllML','MATFileOnly'}))&&~h.BuildOpt.HDLCoderMode;
        h.BuildOpt.MLSysObjClassName=p.Results.MLSysObjClassName;


        firstProc=strcmpi(p.Results.FirstFPGAProcess,firstProcess);
        firstIdx=find(firstProc,1);

        h.BuildOpt.FirstProcess.Run=(firstIdx>1);
        h.BuildOpt.FirstProcess.Cmd=processCmd{firstProc};
        h.BuildOpt.FirstProcess.Name=processName{firstProc};

        finalProc=strcmpi(p.Results.FinalFPGAProcess,finalProcess);
        finalIdx=find(finalProc,1);

        h.BuildOpt.FinalProcess.Run=(finalIdx>firstIdx);
        h.BuildOpt.FinalProcess.Cmd=processCmd{finalProc};
        h.BuildOpt.FinalProcess.Name=processName{finalProc};
    else

        h.BuildOpt.QuestDlg=false;
        h.BuildOpt.NoWarn=false;
        h.BuildOpt.GenHDL=true;
        h.BuildOpt.GenFPGA=true;
        h.BuildOpt.GenSLBlock=true;
        h.BuildOpt.GenMLSysObj=false;
        h.BuildOpt.GenMATFile=true;

        h.BuildOpt.FirstProcess.Run=true;
        h.BuildOpt.FirstProcess.Cmd=processCmd{2};
        h.BuildOpt.FirstProcess.Name=processName{2};

        h.BuildOpt.FinalProcess.Run=true;
        h.BuildOpt.FinalProcess.Cmd=processCmd{5};
        h.BuildOpt.FinalProcess.Name=processName{5};

        h.BuildOpt.MLSysObjClassName='';
        h.BuildOpt.HDLCoderMode=false;
    end

