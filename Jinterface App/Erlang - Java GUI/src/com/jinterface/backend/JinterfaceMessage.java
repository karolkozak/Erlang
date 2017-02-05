package com.jinterface.backend;

import java.io.IOException;

import com.ericsson.otp.erlang.OtpErlangAtom;
import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangExit;
import com.ericsson.otp.erlang.OtpErlangObject;
import com.ericsson.otp.erlang.OtpErlangPid;
import com.ericsson.otp.erlang.OtpErlangString;
import com.ericsson.otp.erlang.OtpErlangTuple;
import com.ericsson.otp.erlang.OtpMbox;
import com.ericsson.otp.erlang.OtpNode;

public class JinterfaceMessage {
	private static String server = "server";
	private OtpNode self = null;
	private OtpMbox mbox = null;
	OtpErlangObject[] msg;
	OtpErlangTuple tuple;
	
	public JinterfaceMessage()  {
		try {
            self = new OtpNode("mynode", "test");
            mbox = self.createMbox("facserver");
        } catch (IOException e1) {
            e1.printStackTrace();
        }
		msg = new OtpErlangObject[2];
		msg[0] = mbox.self();
	}
	
	public boolean start() {
		if (self.ping(server, 2000))
            return true;
        else
            return false;
	}
	
	OtpErlangObject receivedObject;
	OtpErlangTuple receivedTuple;
	OtpErlangPid fromPid;
	OtpErlangObject receivedMessage;
	
	public void send(String message) {
		msg[1] = new OtpErlangString(message);
        tuple = new OtpErlangTuple(msg);
		mbox.send("mess", server, tuple);
		
		try {
			receivedObject = mbox.receive();
			receivedTuple = (OtpErlangTuple) receivedObject;
			fromPid = (OtpErlangPid) (receivedTuple.elementAt(0));
			receivedMessage = receivedTuple.elementAt(1);
		} catch (OtpErlangExit e) {
			e.printStackTrace();
		} catch (OtpErlangDecodeException e) {
			e.printStackTrace();
		}
	}
	
	public String getMessage(){
		return receivedMessage.toString();
	}
	
	public void stop() {
		OtpErlangAtom ok = new OtpErlangAtom("stop");
        mbox.send(fromPid, ok);
	}
}
