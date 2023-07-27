// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Communicator.java

package com.mathworks.addons_common.matlabonline;

import com.mathworks.messageservice.*;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common.matlabonline:
//            MessageHandler, MessageFromClient, MessageFromServer

public final class Communicator
{

    public Communicator()
    {
    }

    private static void subscribe()
    {
        MessageServiceFactory.getMessageService().subscribe("/matlab/addons/clientToServer", getSubscriber());
    }

    private static Subscriber getSubscriber()
    {
        return new Subscriber() {

            public void handle(Message message)
            {
                try
                {
                    Map map = Communicator.getReceivedMessageData(message);
                    String s = (String)map.get("type");
                    if(!s.toString().equalsIgnoreCase(MessageFromClient.OPEN_EXPLORER_WITH_RESOLVED_URL.toString()) && !s.toString().equalsIgnoreCase(MessageFromClient.SHOW_RESOLVED_URL_IN_EXPLORER.toString()) && !s.toString().equalsIgnoreCase(MessageFromClient.OPEN_RESOLVED_INSTALLER_URL_IN_MANAGER.toString()))
                        Communicator.getHandler(MessageFromClient.getMatch(s)).execute(map);
                }
                catch(Exception exception) { }
            }

        }
;
    }

    public static void sendMessageToMatlabOnline(MessageFromServer messagefromserver, Object obj)
    {
        Map map = constructMessageToBePublished(messagefromserver, obj);
        MessageServiceFactory.getMessageService().publish("/matlab/addons/serverToClient", map);
    }

    public static void sendMessageToMatlabOnline(MessageFromServer messagefromserver)
    {
        HashMap hashmap = new HashMap();
        hashmap.put("type", messagefromserver.toString());
        MessageServiceFactory.getMessageService().publish("/matlab/addons/serverToClient", hashmap);
    }

    private static Map getReceivedMessageData(Message message)
    {
        return (Map)message.getData();
    }

    private static Map constructMessageToBePublished(MessageFromServer messagefromserver, Object obj)
    {
        HashMap hashmap = new HashMap();
        hashmap.put("type", messagefromserver.toString());
        hashmap.put("body", obj);
        return hashmap;
    }

    public static void registerHandler(MessageFromClient messagefromclient, MessageHandler messagehandler)
    {
        if(messageHandlerMap.isEmpty())
            subscribe();
        if(!messageHandlerMap.containsKey(messagefromclient))
            messageHandlerMap.put(messagefromclient, messagehandler);
    }

    private static MessageHandler getHandler(MessageFromClient messagefromclient)
    {
        return (MessageHandler)messageHandlerMap.get(messagefromclient);
    }

    private static final String SERVER_TO_CLIENT_CHANNEL = "/matlab/addons/serverToClient";
    private static final String CLIENT_TO_SERVER_CHANNEL = "/matlab/addons/clientToServer";
    private static Map messageHandlerMap = new EnumMap(com/mathworks/addons_common/matlabonline/MessageFromClient);



}
