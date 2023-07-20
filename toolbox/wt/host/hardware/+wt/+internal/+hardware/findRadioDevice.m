function[list,result]=findRadioDevice(varargin)




    uhd_bin_path=wt.internal.uhd.clibgen.setup();
    deviceCount=0;
    addr=[];
    second_addr=[];
    mgmt_addr=[];
    serial="";
    product="";
    list=[];
    pim=wt.internal.hardware.PluginManager.getInstance();
    allp=pim.listPlugins;
    command=fullfile(uhd_bin_path,"uhd_find_devices")+" --args ";

    if nargin==1
        switch lower(varargin{1})
        case "x310"
            case_coerced_product_name="X310";
        otherwise
            case_coerced_product_name=lower(string(varargin{1}));
        end
        [status,result]=system(command+"product="+case_coerced_product_name);
    else
        [status,result]=system(command+"find_all=1");
    end
    if status==0
        rawLines=strsplit(result,'\n');
        rawLines=rawLines(2:end);
        for n=1:length(rawLines)
            strippedLine=strip(string(rawLines(n)),'both');
            if contains(strippedLine,"UHD Device")
                deviceCount=deviceCount+1;
            elseif contains(strippedLine,'mgmt_addr')
                tmp=strsplit(strippedLine,": ");
                mgmt_addr=[mgmt_addr,tmp(2)];%#ok<AGROW>
            elseif contains(strippedLine,'addr')
                tmp=strsplit(strippedLine,": ");
                addr=[addr,tmp(2)];%#ok<AGROW>
            elseif contains(strippedLine,'second_addr')
                tmp=strsplit(strippedLine,": ");
                second_addr=[second_addr,tmp(2)];%#ok<AGROW>
            elseif contains(strippedLine,'serial')
                tmp=strsplit(strippedLine,": ");
                serial=tmp(2);
            elseif contains(strippedLine,'product')
                tmp=strsplit(strippedLine,": ");
                product=upper(tmp(2));
            end



            if n==length(rawLines)||(deviceCount&&contains(rawLines(n+1),"UHD Device"))

                if ismember(product,allp)
                    if product~=""
                        r=wt.internal.hardware.RadioDevice(product);
                    end
                    if~isempty(addr)||~isempty(mgmt_addr)

                        switch product
                        case 'X310'
                            switch length(addr)
                            case 1

                                r.SFP1IPAddress=addr(1);
                            case 2


                                r.SFP0IPAddress=addr(1);
                                r.SFP1IPAddress=addr(2);
                            end
                        otherwise
                            switch length(mgmt_addr)
                            case 1

                                r.SFP1IPAddress=mgmt_addr;
                                r.ManagementIPAddress=mgmt_addr;
                            case 2

                                r.SFP1IPAddress=addr(1);
                                r.SFP0IPAddress=mgmt_addr((~contains(mgmt_addr,addr(1))));
                                r.ManagementIPAddress=r.SFP1IPAddress;
                            case 3


                                r.SFP1IPAddress=addr(1);
                                secondaryAddresses=mgmt_addr((~contains(mgmt_addr,addr(1))));
                                r.SFP0IPAddress=secondaryAddresses(1);
                                r.ManagementIPAddress=secondaryAddresses(2);
                            end
                        end
                    else

                        r.SFP0IPAddress=addr(1);
                        r.SFP1IPAddress=second_addr(1);
                    end
                end
                if serial~=""
                    r.SerialNum=serial;
                end

                list=[list,r];%#ok<AGROW>

                addr=[];
                second_addr=[];
                mgmt_addr=[];
                serial="";
                product="";
            end
        end
    end
