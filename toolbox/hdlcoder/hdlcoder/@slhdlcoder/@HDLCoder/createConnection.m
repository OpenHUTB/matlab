function createConnection(this,snn)


    if isempty(snn)
        snn=this.ModelName;
        if isempty(snn)
            warning(message('hdlcoder:engine:nosnn'));
        else
            this.setStartNodeName(snn);
        end
    end

    if isempty(this.ModelConnection)||~strcmp(snn,this.ModelConnection.System)
        this.ModelConnection=slhdlcoder.SimulinkConnection(snn);
    end
end
