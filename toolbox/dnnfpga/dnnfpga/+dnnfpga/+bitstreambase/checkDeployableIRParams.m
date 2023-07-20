
function[hasConv,hasFC,convModuleIR,fcModuleIR,inputModuleIR]=checkDeployableIRParams(deployableIRParams)




    hasConv=false;
    convModuleIR=[];
    hasFC=false;
    fcModuleIR=[];
    inputModuleIR=[];
    for ii=1:length(deployableIRParams)
        moduleIR=deployableIRParams{ii};
        moduleIRType=moduleIR.type;
        switch moduleIRType
        case 'FPGA_Conv'
            hasConv=true;
            convModuleIR=moduleIR;
        case 'FPGA_FC'
            hasFC=true;
            fcModuleIR=moduleIR;
        case 'SW_SeriesNetwork'
            if strcmpi(moduleIR.params{1}.internal_type,...
                'SW_SeriesNetwork_Input')
                inputModuleIR=moduleIR;
            end
        otherwise

        end
    end

end


