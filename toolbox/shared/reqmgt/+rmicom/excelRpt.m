function out=excelRpt(method)



    persistent our_excel;

    out=[];
    switch(lower(method))

    case 'setup'




        our_excel=[];
        out=1;
        while rmicom.excelApp('exists')

            rmicom.excelApp('clear');
            mRetry=getString(message('Slvnv:reqmgt:linktype_rmi_excel:Retry'));
            mCancel=getString(message('Slvnv:reqmgt:linktype_rmi_excel:Cancel'));
            mContinue=getString(message('Slvnv:rmiref:DocCheckExcel:Continue'));
            selection=questdlg({...
            getString(message('Slvnv:reqmgt:com_excel_check_app:ExcelAppearsToBeRunning')),...
            '',...
            getString(message('Slvnv:reqmgt:com_excel_check_app:IfYouContinue'))},...
            getString(message('Slvnv:reqmgt:com_excel_check_app:MicrosoftExcelRunning')),...
            mRetry,mContinue,mCancel,mRetry);
            if isempty(selection)
                selection=mRetry;
            end
            switch selection,
            case mRetry,
                out=1;
                continue;
            case mCancel,
                out=0;
                break;
            case mContinue
                out=1;
                break;
            end
        end


    case 'init'






        if~isempty(our_excel)
            try
                our_excel.Close();
            catch Mex %#ok<NASGU>
            end
            our_excel=[];
        end




        if rmicom.excelApp('exists')
            rmi.mdlAdvState('excel',-1);
            error(message('Slvnv:reqmgt:com_excel_check_app:ExcelSessionDetected'));
        else



            our_excel=rmicom.excelApp('get');
            our_excel.Visible=1;

            rmi.mdlAdvState('excel',1);
            out=our_excel;
        end

    case 'get'


        if isempty(our_excel)
            our_excel=rmicom.excelApp('get');
            our_excel.Visible=1;
        else
            try
                our_excel.Visible=1;
            catch Mex %#ok<NASGU>
                our_excel=rmicom.excelApp('get');
                our_excel.Visible=1;
            end
        end
        out=our_excel;


    case 'destroy'





        our_excel=[];
        rmicom.excelApp('kill');

    case 'clear'


        our_excel=[];
    end
end



