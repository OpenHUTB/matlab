function addSection( rpt, id, title, summary, contents, options )

arguments
    rpt
    id
    title
    summary
    contents
    options.Collapse( 1, 1 )logical = false
    options.Tag char = 'h3'
end

rpt.sectionNum = rpt.sectionNum + 1;
aTitle = Advisor.Element;
aTitle.setTag( options.Tag );
if rpt.AddSectionNumber
    aTitle.setContent( [ int2str( rpt.sectionNum ), '. ', title ] );
else
    aTitle.setContent( title );
end
name = [ 'sec_', strrep( title, ' ', '_' ) ];
aTitle.setAttribute( 'name', name );
aTitle.setAttribute( 'id', id );
entries = {  };
if ~isempty( summary )
    entries{ end  + 1, 1 } = summary;
end
if ~isempty( contents )
    entries{ end  + 1, 1 } = contents;
end
if ~isempty( entries )
    t = Advisor.Table( length( entries ), 1 );
    t.setEntries( entries );
    t.setBorder( 0 );
    t.setAttribute( 'width', '100%' );
    if rpt.AddSectionShrinkButton
        rpt.TableID = rpt.TableID + 1;
        tid = [ rpt.getId, '_table_', sprintf( '%03d', rpt.TableID ) ];
        option.UseSymbol = false;
        option.ShowByDefault = options.Collapse;
        if option.ShowByDefault

            t.setAttribute( 'style', 'display: none' );
        end
        option.tooltip = 'Click to shrink or expand section';
        aTitle.setContent( [ aTitle.content, ' ', rpt.getRTWTableShrinkButton( tid, option ) ] );
        t.setAttribute( 'name', tid );
        t.setAttribute( 'id', tid );
    end
    rpt.Doc.addItem( aTitle );
    rpt.Doc.addItem( t );
end
if rpt.AddSectionToToc

    aHref = Advisor.Element;
    aHref.setTag( 'a' );
    aHref.setContent( title );
    aHref.setAttribute( 'href', [ '#', id ] );
    if rpt.AddSectionShrinkButton
        tid = [ rpt.getId, '_table_', sprintf( '%03d', rpt.TableID ) ];
        js = [ 'rtwTableExpand(window.document, window.document.getElementById(''', tid, '_control''), ''', tid, ''')' ];
        aHref.setAttribute( 'onclick', js );
    end
    rpt.TocItems.addItem( aHref );
end
end
