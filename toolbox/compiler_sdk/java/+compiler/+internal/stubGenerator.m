function stub=stubGenerator(fcn)

    sig=compiler.internal.getSig(fcn);


    if(isempty(sig))
        error(message('CompilerSDK:deploytool:FUNCTION_SIGNATURE_ERROR',f))
    else
        [~,name,~]=fileparts(fcn);


        stub="% Sample script to demonstrate execution of function ";
        stub=stub+generateFunctionCall(name,sig.vhInputs,sig.vhOutputs);
        stub=strip(stub,'right',';');
        stub=stub+newline+initializeInputs(sig.vhInputs);
        stub=stub+generateFunctionCall(name,sig.vhInputs,sig.vhOutputs);
    end
end


function fcnCall=generateFunctionCall(name,inputs,outputs)
    fcnCall="";
    if~isempty(outputs)
        if length(outputs)==1
            fcnCall=fcnCall+outputs(1);
        else
            fcnCall=fcnCall+"["+join(outputs,", ")+"]";
        end
        fcnCall=fcnCall+" = ";
    end
    fcnCall=fcnCall+name;

    fcnCall=fcnCall+"(";
    if~isempty(inputs)
        fcnCall=fcnCall+join(inputs,", ");
    end
    fcnCall=fcnCall+");";
end



function inputs=initializeInputs(input)
    inputs="";
    for i=1:length(input)
        inputs=inputs+input(i)+" = 0; % Initialize "+input(i)+" here"+newline;
    end
end