function simrfV2filterexport(block,dialog)

    topBlk=bdroot(block);
    if strcmpi(get_param(topBlk,'BlockDiagramType'),'library')
        return;
    end

    if dialog.hasUnappliedChanges
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:ApplyButton',blkName));
    end

    guiTitle=['Save Filter Parameters From Block ',block];
    [fileName,pathName]=uiputfile({'*.mat;*.txt'},guiTitle,...
    [topBlk,'.mat']);

    if isequal(fileName,0)
        return
    end
    write_file=fullfile(pathName,fileName);

    designOutput=desOutput(get_param(block,'UserData'));
    if isempty(regexp(fileName,'.txt$','once'))
        save(write_file,'-struct','designOutput','-double');
    else
        fid=fopen(write_file,'w+');

        if fid<0
            error(message('simrf:simrfV2errors:CannotOpenFile',fileName));
        end

        charStrs={'FilterType','ResponseType','Implementation','Topology'};
        prtOrder={'FilterType','ResponseType','Implementation','Topology'...
        ,'FilterOrder','PassbandFrequency','PassbandAttenuation'...
        ,'StopbandFrequency','StopbandAttenuation','Zin','Zout'...
        ,'Denominator','Numerator21','Numerator11','Numerator22'...
        ,'Inductors','Capacitors','Wx'};
        fldNames=fieldnames(designOutput);
        [~,fldLoc]=ismember(prtOrder,fldNames);
        for f_idx=fldLoc(fldLoc~=0)
            fld_name=fldNames{f_idx};
            if any(strcmp(fld_name,charStrs))
                fprintf(fid,'%s: %s\n\n',fld_name,designOutput.(fld_name));
            else
                for q_idx=1:size(designOutput.(fld_name),1)
                    if q_idx==1
                        restring(sprintf('%s = %s\n',fld_name,...
                        simrfV2vector2str(designOutput.(fld_name)(1,:))),0,fid);
                        fprintf(fid,'\n');
                    else
                        restring(sprintf('    %s\n',...
                        simrfV2vector2str(designOutput.(fld_name)(q_idx,:))),0,fid);
                        fprintf(fid,'\n');
                    end
                end
            end
        end
        fclose(fid);
    end
end


function restring(instring,varargin)
    narginchk(1,3);
    if nargin<2
        indent_level=0;
    else
        indent_level=varargin{1};
    end
    if nargin<3
        fid=1;
    else
        fid=varargin{2};
    end
    instring=regexprep([blanks(4*indent_level),instring],'\s+$','');
    while length(instring)>75
        char_pos=regexp(instring,' ');
        cut_char_pos=char_pos(find(char_pos<=70,1,'last'));
        validateattributes(cut_char_pos,{'numeric'},{'<=',75},...
        '','cut_char_pos')
        fprintf(fid,'%s%*s\n',instring(1:cut_char_pos),...
        75-cut_char_pos,'...');
        instring=[blanks(4*(indent_level+1))...
        ,strtrim(instring(cut_char_pos+1:end))];
    end
    fprintf(fid,'%s\n',instring);
end


function desStruct=desOutput(uData)
    uDesData=uData.DesignData;
    prtBaseObj={'FilterType','ResponseType','Implementation','Zin','Zout'};
    switch lower(uData.FilterType)
    case 'butterworth'
        switch lower(uData.Implementation)
        case 'transfer function'
            switch lower(uData.ResponseType)
            case{'lowpass','highpass'}
                prtObjData=[prtBaseObj,{'PassbandFrequency'...
                ,'PassbandAttenuation'}];
                prtDesData={'FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={};
                dataAux={};
            case 'bandpass'
                prtObjData=[prtBaseObj,{'PassbandAttenuation'}];
                prtDesData={'PassbandFrequency','FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            case 'bandstop'
                prtObjData=[prtBaseObj,{'StopbandAttenuation'}];
                prtDesData={'StopbandFrequency','FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            end
        otherwise
            switch lower(uData.ResponseType)
            case{'lowpass','highpass'}
                prtObjData=prtBaseObj;
                prtDesData={'FilterOrder','PassbandFrequency','Topology'...
                ,'PassbandAttenuation','Capacitors','Inductors'};
                prtAuxData={};
                dataAux={};
            case 'bandpass'
                prtObjData=prtBaseObj;
                prtDesData={'FilterOrder','PassbandFrequency','Topology'...
                ,'PassbandAttenuation','Capacitors','Inductors'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            case 'bandstop'
                prtObjData=[prtBaseObj...
                ,{'StopbandAttenuation'}];
                prtDesData={'FilterOrder','Topology','StopbandFrequency'...
                ,'Capacitors','Inductors'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            end
        end

    case 'chebyshev'
        switch lower(uData.Implementation)
        case 'transfer function'
            switch lower(uData.ResponseType)
            case{'lowpass','highpass'}
                prtObjData=[prtBaseObj,{'PassbandAttenuation'}];
                prtDesData={'PassbandFrequency','FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={};
                dataAux={};
            case 'bandpass'
                prtObjData=[prtBaseObj,{'PassbandAttenuation'}];
                prtDesData={'PassbandFrequency','FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            case 'bandstop'
                prtObjData=[prtBaseObj...
                ,{'PassbandAttenuation','StopbandAttenuation'}];
                prtDesData={'StopbandFrequency','FilterOrder'...
                ,'Denominator','Numerator21','Numerator11','Numerator22'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            end
        otherwise
            switch lower(uData.ResponseType)
            case{'lowpass','highpass'}
                prtObjData=prtBaseObj;
                prtDesData={'FilterOrder','PassbandFrequency','Topology'...
                ,'PassbandAttenuation','Capacitors','Inductors'};
                prtAuxData={};
                dataAux={};
            case 'bandpass'
                prtObjData=prtBaseObj;
                prtDesData={'FilterOrder','PassbandFrequency','Topology'...
                ,'PassbandAttenuation','Capacitors','Inductors'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            case 'bandstop'
                prtObjData=[prtBaseObj...
                ,{'PassbandAttenuation','StopbandAttenuation'}];
                prtDesData={'FilterOrder','Topology','StopbandFrequency'...
                ,'Capacitors','Inductors'};
                prtAuxData={'Wx'};
                dataAux=uDesData.Auxiliary.Wx;
            end
        end

    case 'inversechebyshev'
        prtAuxData={};
        dataAux={};
        switch lower(uData.ResponseType)
        case{'lowpass','highpass'}
            prtObjData=[prtBaseObj,{'PassbandFrequency'...
            ,'PassbandAttenuation','StopbandAttenuation'}];
            prtDesData={'StopbandFrequency','FilterOrder'...
            ,'Denominator','Numerator21','Numerator11','Numerator22'};
        case 'bandpass'
            prtObjData=[prtBaseObj,{'PassbandFrequency'...
            ,'PassbandAttenuation','StopbandAttenuation'}];
            prtDesData={'StopbandFrequency','FilterOrder'...
            ,'Denominator','Numerator21','Numerator11','Numerator22'};
            prtAuxData={'Wx'};
            dataAux=uDesData.Auxiliary.Wx;
        case 'bandstop'
            prtObjData=[prtBaseObj,{'StopbandFrequency'...
            ,'StopbandAttenuation'}];
            prtDesData={'FilterOrder'...
            ,'Denominator','Numerator21','Numerator11','Numerator22'};
        end
    end

    dataObj=cellfun(@(x)uData.(x),prtObjData,'UniformOutput',false);
    dataDes=cellfun(@(x)uDesData.(x),prtDesData,'UniformOutput',false);
    prtData=[dataObj,dataDes,dataAux];
    prtNames=[prtObjData,prtDesData,prtAuxData];
    desStruct=cell2struct(prtData,prtNames,2);
end


