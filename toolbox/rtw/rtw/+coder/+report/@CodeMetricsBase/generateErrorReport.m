function generateErrorReport(obj)




    ccm=obj.Data;
    obj.AddSectionShrinkButton=false;
    obj.AddSectionToToc=false;
    obj.AddSectionNumber=false;
    if strcmp(ccm.LatestStatus.Status,'failed')

        tf=ismember({ccm.LatestStatus.Reason.kind},'error');
        err_files={ccm.LatestStatus.Reason(tf).file};
        err_lines=cell(size(err_files));
        eLines=[ccm.LatestStatus.Reason(tf).line];
        for i=1:length(eLines)
            err_lines{i}=int2str(eLines(i));
        end
        err_details={ccm.LatestStatus.Reason(tf).desc};
        [~,I]=unique(strcat(err_files,err_lines,err_details));
        err_Table={[obj.msgs.file_msg,err_files(I)]',[obj.msgs.line_msg,err_lines(I)]',[obj.msgs.description_msg,err_details(I)]'};
        option.HasHeaderRow=true;
        option.HasBorder=true;
        table=obj.createTable(err_Table,option,[4,1,3],{'left','left','left'});
        obj.addSection('sec_error_report',obj.getMessage('ErrorReport'),obj.msgs.fail_msg,table);
    elseif strcmp(ccm.LatestStatus.Status,'notSupportCPP')
        fileList=Advisor.List;
        files=ccm.FileList;
        for i=1:length(files)
            [~,~,ext]=fileparts(files{i});
            if strcmpi(ext,'.cpp')
                fileList.addItem(files{i});
            end
        end
        obj.addSection('sec_error_report',obj.getMessage('ErrorReport'),obj.msgs.notSupportCPP_msg,fileList.emitHTML);
    end
end
