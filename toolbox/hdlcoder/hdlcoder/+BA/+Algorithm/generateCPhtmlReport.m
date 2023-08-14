function generateCPhtmlReport(fid,cpir,rootPIR)




    if(nargin<1)
        fid=1;
    end

    fprintf(fid,'<html>\r\n');
    fprintf(fid,'<head>\r\n');
    fprintf(fid,'<title>HDL Resource Utilization Report for </title>\r\n');
    fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\r\n');
    fprintf(fid,'<style type="text/css">\r\n');
    fprintf(fid,'td.Header {\r\n');
    fprintf(fid,'  width: 40%%;\r\n');
    fprintf(fid,'  border: 1px solid #000;\r\n');
    fprintf(fid,'  text-align:center;\r\n');
    fprintf(fid,'}\r\n');
    fprintf(fid,'\r\n');
    fprintf(fid,'td.rawSignalName, td.abstractSignalName {\r\n');
    fprintf(fid,'  width: 40%%;\r\n');
    fprintf(fid,'  border: 1px solid #000;\r\n');
    fprintf(fid,'  text-align:left;\r\n');
    fprintf(fid,'}\r\n');
    fprintf(fid,'td.delay {\r\n');
    fprintf(fid,'  width: 20%%;\r\n');
    fprintf(fid,'  border: 1px solid #000;\r\n');
    fprintf(fid,'  text-align:center;\r\n');
    fprintf(fid,'}\r\n');
    fprintf(fid,'</style>\r\n');
    fprintf(fid,'</head>\r\n');
    fprintf(fid,'</head>\r\n');
    fprintf(fid,'<body bgcolor="#FFFFFF" text="#000000">\r\n');
    fprintf(fid,'\r\n');
    fprintf(fid,'<h1>Critical Paths Summary</h1>\r\n');
    fprintf(fid,'');
    for nn=1:cpir.getNumCPs
        cpir.abstractOutCP(nn,rootPIR);
        cp=cpir.getAbstractedCP(nn);
        if cpir.getNumNodes(nn)==0
            continue
        end
        fprintf(fid,'\t\r\n');
        fprintf(fid,'<h2>Critial path (');
        fprintf(fid,'%s',int2str(nn));
        fprintf(fid,')</h2>\r\n');
        fprintf(fid,'<table style="border:2px solid black; width:75%%;">\r\n');
        fprintf(fid,'<tr style="background-color: #990000">\r\n');
        fprintf(fid,'<td class="Header" align="left"><font face="Arial, Helvetica, sans-serif" color="#ffffff">Raw</font></td>\r\n');
        fprintf(fid,'<td class="Header" align="left"><font face="Arial, Helvetica, sans-serif" color="#ffffff">Abstract</font></td>\r\n');
        fprintf(fid,'</tr>\r\n');
        fprintf(fid,'<tr>\r\n');
        fprintf(fid,'<td style="vertical-align: top; padding: 10;">\r\n');
        fprintf(fid,'<table style="border:2px; width:100%%;">\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'');
        for ii=1:cpir.getNumNodes(nn)
            thisNode=cpir.getEntireCPNode(nn,ii);
            fprintf(fid,'\r\n');
            fprintf(fid,'');
            if mod(ii,2)==1
                fprintf(fid,'\r\n');
                fprintf(fid,'<TR style="background-color: #eeeeff; ">\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'');
                if length(thisNode.identifier)==1
                    fprintf(fid,'         \r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',thisNode.identifier{:});
                    fprintf(fid,'</TD>\r\n');
                    fprintf(fid,'');
                else
                    fprintf(fid,'\r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',BA.Main.baDriver.getFullPath(thisNode.identifier,'Altera'));
                    fprintf(fid,'</TD>\t\t\t\r\n');
                    fprintf(fid,'');
                end
                fprintf(fid,'\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'<td style="border-style: none;background-color: #C0504D; width: 20%%; text-align:center"><font face="Arial, Helvetica, sans-serif" color="#ffffff">');
                fprintf(fid,'%4.3f',thisNode.cumulativeDelay);
                fprintf(fid,'</font></td>\r\n');
                fprintf(fid,'');
            else
                fprintf(fid,'\r\n');
                fprintf(fid,'<TR style="background-color: #ffffff">\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'');
                if length(thisNode.identifier)==1
                    fprintf(fid,'         \r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',thisNode.identifier{:});
                    fprintf(fid,'</TD>\r\n');
                    fprintf(fid,'');
                else
                    fprintf(fid,'\r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',BA.Main.baDriver.getFullPath(thisNode.identifier,'Altera'));
                    fprintf(fid,'</TD>\t\t\t\r\n');
                    fprintf(fid,'');
                end
                fprintf(fid,'\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'<td style="border-style: none;background-color: #DFA7A6; width: 20%%; text-align:center"><font face="Arial, Helvetica, sans-serif" color="#ffffff">');
                fprintf(fid,'%4.3f',thisNode.cumulativeDelay);
                fprintf(fid,'</font></td>\r\n');
                fprintf(fid,'');
            end
            fprintf(fid,'\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'');
        end
        fprintf(fid,'\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'</table>\r\n');
        fprintf(fid,'</td>\r\n');
        fprintf(fid,'<td style="vertical-align: top; padding: 10;">\r\n');
        fprintf(fid,'<table style="border:2px; width:100%%;">\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'');
        for ii=1:cp.numNodes
            thisNode=cp.getNode(ii);
            fprintf(fid,'\r\n');
            fprintf(fid,'');
            if mod(ii,2)==1
                fprintf(fid,'\r\n');
                fprintf(fid,'<TR style="background-color: #eeeeff">\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'');
                if length(thisNode.identifier)==1
                    fprintf(fid,'         \r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',thisNode.identifier.name);
                    fprintf(fid,'</TD>\r\n');
                    fprintf(fid,'');
                else
                    fprintf(fid,'\r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',BA.Main.baDriver.getFullPath(thisNode.identifier,'Altera'));
                    fprintf(fid,'</TD>\t\t\t\r\n');
                    fprintf(fid,'');
                end
                fprintf(fid,'\r\n');
                fprintf(fid,'\r\n');
                fprintf(fid,'<td style="border-style: none;background-color: #C0504D; width: 20%%; text-align:center"><font face="Arial, Helvetica, sans-serif" color="#ffffff">');
                fprintf(fid,'%4.3f',thisNode.cumulativeDelay);
                fprintf(fid,'</font></td>\r\n');
                fprintf(fid,'');
            else
                fprintf(fid,'\r\n');
                fprintf(fid,'<TR style="background-color: #ffffff">\r\n');
                fprintf(fid,'');
                if length(thisNode.identifier)==1
                    fprintf(fid,'         \r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',thisNode.identifier.name);
                    fprintf(fid,'</TD>\r\n');
                    fprintf(fid,'');
                else
                    fprintf(fid,'\r\n');
                    fprintf(fid,'<TD style="border-style: none" align="left">');
                    fprintf(fid,'%s',BA.Main.baDriver.getFullPath(thisNode.identifier,'Altera'));
                    fprintf(fid,'</TD>\t\t\t\r\n');
                    fprintf(fid,'');
                end
                fprintf(fid,'\r\n');
                fprintf(fid,'<td style="border-style: none;background-color: #DFA7A6; width: 20%%; text-align:center"><font face="Arial, Helvetica, sans-serif" color="#ffffff">');
                fprintf(fid,'%4.3f',thisNode.cumulativeDelay);
                fprintf(fid,'</font></td>\r\n');
                fprintf(fid,'');
            end
            fprintf(fid,'\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'\r\n');
            fprintf(fid,'');
        end
        fprintf(fid,'\r\n');
        fprintf(fid,'</table>\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'</td>\r\n');
        fprintf(fid,'</tr>\r\n');
        fprintf(fid,'</table>\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'\r\n');
        fprintf(fid,'<hr>\r\n');
        fprintf(fid,'<P></P>\r\n');
        fprintf(fid,'<P></P>\r\n');
        fprintf(fid,'');
    end
    fprintf(fid,'\r\n');
    fprintf(fid,'\r\n');
    fprintf(fid,'\r\n');
    fprintf(fid,'</body>\r\n');
    fprintf(fid,'</html>');
end
