function addInterconnect(fid,hbuild)

    intc_gp=hbuild.Interconnect;

    num_master=numel(intc_gp.master);
    num_slave=numel(intc_gp.slave);
    if~isempty(num_master)||~isempty(num_slave)
        fprintf(fid,'# Add interface connections\n');
    end

    for idx_s=1:num_slave
        s_source=intc_gp.slave(idx_s).name;
        s_usage=intc_gp.slave(idx_s).usage;
        s_offset=intc_gp.slave(idx_s).offset;
        for idx_m=1:num_master
            m_source=intc_gp.master(idx_m).name;
            m_usage=intc_gp.master(idx_m).usage;
            if strcmpi(m_usage,'all')||strcmpi(m_usage,s_usage)
                if strcmpi(m_usage,'all')&&strcmpi(s_usage,'memPS')
                    break;
                end
                fprintf(fid,'add_connection %s %s\n',m_source,s_source);
                fprintf(fid,'set_connection_parameter_value %s/%s arbitrationPriority {1}\n',m_source,s_source);
                fprintf(fid,'set_connection_parameter_value %s/%s baseAddress {%s}\n',m_source,s_source,s_offset);
                fprintf(fid,'set_connection_parameter_value %s/%s defaultConnection {0}\n\n',m_source,s_source);
            end
        end
    end
end
