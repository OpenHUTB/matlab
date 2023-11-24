function bPrev=setDeferRMIPostLoadActions(b)
    tf=slreq.internal.TempFlags.getInstance();
    bPrev=tf.get('DeferModelPostLoadActions');
    tf.set('DeferModelPostLoadActions',b);

end

