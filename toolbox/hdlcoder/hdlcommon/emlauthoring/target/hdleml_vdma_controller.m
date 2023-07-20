%#codegen
function[SOF_out,EOL_out,EOF_out]=hdleml_vdma_controller(...
    num_of_col,num_of_row)




    coder.allowpcode('plain')

    persistent vcstate rowcnt colcnt
    if isempty(vcstate)
        vcstate=uint8(0);
        rowcnt=fi(0,0,11,0);
        colcnt=fi(0,0,11,0);
    end


    switch uint8(vcstate)

    case 0
        rowcnt(:)=0;
        colcnt(:)=0;
        SOF_out=true;
        EOL_out=false;
        EOF_out=false;

        vcstate(:)=2;

    case 1
        SOF_out=false;
        EOL_out=false;
        EOF_out=false;
        colcnt(:)=0;

        vcstate(:)=2;

    case 2
        SOF_out=false;
        EOL_out=false;
        EOF_out=false;
        colcnt(:)=colcnt+1;

        if colcnt==num_of_col-2
            vcstate(:)=3;
        else
            vcstate(:)=2;
        end

    case 3
        SOF_out=false;
        EOL_out=true;
        rowcnt(:)=rowcnt+1;

        if rowcnt==num_of_row
            EOF_out=true;
            vcstate(:)=0;
        else
            EOF_out=false;
            vcstate(:)=1;
        end

    otherwise
        rowcnt(:)=0;
        colcnt(:)=0;
        SOF_out=false;
        EOL_out=false;
        EOF_out=false;
        vcstate(:)=0;
    end

end



