function line1=warnNonDefaultPort(portNumber,isUI)

    httpPortErrorID='Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortTitle';
    if portNumber==0
        line1=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorRequired1'));
        line2=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorRequired2'));
        line3=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorRequired3'));
    else
        line1=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine1',num2str(portNumber)));
        line2=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine2'));
        line3=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine3'));
    end
    if isUI
        dlgTitle=getString(message(httpPortErrorID));
        errordlg({line1,line2,line3},dlgTitle,'modal');
    else
        me=MException(httpPortErrorID,[line1,newline,line2,newline,line3]);
        throwAsCaller(me);
    end
end
