function out=traverseTabs(this,d,dlgH,imNode)





    if isa(imNode,'DAStudio.imTabBar')
        out=d.createDocumentFragment;
        tabIdx=0;
        tabChild=imNode.down;
        while(~isempty(tabChild))



            imNode.setTab(tabIdx);


            childOut=traverseTabs(this,d,dlgH,tabChild);
            if(isempty(childOut))


                try
                    out.appendChild(this.gr_makeGraphic(d,dlgH));
                catch ex
                    this.status(getString(message('rptgen:RptDialogSnapshot:UnableToSnapshot')));
                    this.status(ex.message,5);
                end
            else

                out.appendChild(childOut);
            end

            tabIdx=tabIdx+1;
            tabChild=tabChild.right;
        end
    else

        out=[];

        nodeChild=imNode.down;
        while(~isempty(nodeChild))

            childOut=traverseTabs(this,d,dlgH,nodeChild);
            if(~isempty(childOut))
                if(isempty(out))
                    out=childOut;
                else

                    out.appendChild(childOut);
                end
            end
            nodeChild=nodeChild.right;
        end
    end


