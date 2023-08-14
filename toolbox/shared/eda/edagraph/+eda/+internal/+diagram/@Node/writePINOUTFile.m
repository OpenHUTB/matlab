function writePINOUTFile(this)


    path=hdlGetCodegendir(true);
    if isempty(path)
        path='script';
        mkdir(path);
    end




    filePath=fullfile(matlabroot,'toolbox','shared','eda','fpgaautomation','+eda','+avnet','@AES_SP3ADSP','aes_sp3adsp.ucf');

    for i=1:length(this.ChildNode)
        Child=this.ChildNode{i};
        if isa(Child,'eda.internal.component.FPGA')
            copyfile(filePath,[path,'/aes_sp3adsp.ucf'],'f');
        end
    end

end
