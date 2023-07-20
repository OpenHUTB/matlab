function SetInternalDriveModel(driveType,AverageValue,block);%#ok












    if(strcmp(driveType,'AC1')||strcmp(driveType,'AC4')||strcmp(driveType,'AC9'))
        return;
    end


    [blocksToSet,idxBlock,inverterType]=getSpsDrivesConfig(driveType);
    WantAverageValueModel=AverageValue==1;
    HaveAverageValueModel=strcmp(get_param([getfullname(block),'/',blocksToSet{1}],'detailLevel'),'Average');



    if~bdIsLibrary(bdroot(block))

        if WantAverageValueModel
            for i=1:length(blocksToSet)
                thisBlock=[getfullname(block),'/',blocksToSet{i}];
                try
                    set_param(thisBlock,'detailLevel','Average');
                catch ME
                    errordlg(['Error in function ''',mfilename,''' when trying ',...
                    'to write to block''',thisBlock,''' mask. ',...
                    'Error message from matlab is:',newline,newline,ME.message]);
                end
            end
            switch driveType
            case{'AC2','AC3','AC5','AC6','AC7'}
                try
                    set_param([getfullname(block),'/',blocksToSet{idxBlock}],'driveType',inverterType);
                catch ME
                    errordlg(['Error in function ''',mfilename,''' when trying ',...
                    'to write to block''',blocksToSet{idxBlock},''' mask. ',...
                    'Error message from matlab is:',newline,newline,ME.message]);
                end
            end
        elseif~WantAverageValueModel
            for i=1:length(blocksToSet)
                thisBlock=[getfullname(block),'/',blocksToSet{i}];
                try
                    set_param(thisBlock,'detailLevel','Detailed');
                catch ME
                    errordlg(['Error in function ''',mfilename,''' when trying ',...
                    'to write to block''',thisBlock,''' mask. ',...
                    'Error message from matlab is:',newline,newline,ME.message]);
                end
            end
        end
    end

    function[blocksToSet,idxBlock,driveType]=getSpsDrivesConfig(driveType)







        switch driveType
        case 'AC2'
            blocksToSet{1}='SVM generator';
            blocksToSet{2}='Three-phase Inverter';
            driveType='Space Vector Modulation';
            idxBlock=2;
        case 'AC3'
            blocksToSet{1}='Three-phase Inverter';
            blocksToSet{2}='F.O.C.';
            blocksToSet{3}='Mux';
            driveType='Field-Oriented Control';
            idxBlock=1;
        case 'AC5'
            blocksToSet{1}='Vector control';
            blocksToSet{2}='Three-phase Inverter';
            blocksToSet{3}='Mux';
            blocksToSet{4}='Active rectifier';
            driveType='WFSM Vector Control';
            idxBlock=2;
        case 'AC6'
            blocksToSet{1}='Three-phase Inverter';
            blocksToSet{2}='VECT';
            blocksToSet{3}='Mux';
            driveType='PMSM Vector Control';
            idxBlock=1;
        case 'AC7'
            blocksToSet{1}='Three-phase Inverter';
            blocksToSet{2}='Current Controller';
            blocksToSet{3}='Mux';
            driveType='Brushless DC';
            idxBlock=1;
        case 'AC8'
            blocksToSet{1}='Five-phase Inverter';
            blocksToSet{2}='VECT';
            blocksToSet{3}='Mux';
            driveType=[];
            idxBlock=[];
        case 'DC1'
            blocksToSet{1}='Thyristor converter';
            blocksToSet{2}='Bridge firing unit';
            driveType=[];
            idxBlock=[];
        case 'DC2'
            blocksToSet{1}='Thyristor converter 1';
            blocksToSet{2}='Thyristor converter 2';
            blocksToSet{3}='Bridge firing unit';
            driveType=[];
            idxBlock=[];
        case 'DC3'
            blocksToSet{1}='Thyristor converter';
            blocksToSet{2}='Bridge firing unit';
            driveType=[];
            idxBlock=[];
        case{'DC4'}
            blocksToSet{1}='Thyristor converter 1';
            blocksToSet{2}='Thyristor converter 2';
            blocksToSet{3}='Bridge firing unit';
            driveType=[];
            idxBlock=[];
        case{'DC5','DC6','DC7'}
            blocksToSet{1}='Chopper';
            blocksToSet{2}='Current controller';
            driveType=[];
            idxBlock=[];
        end
