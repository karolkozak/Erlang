package com.jinterface.GUI;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTextArea;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import com.ericsson.otp.erlang.OtpErlangString;
import com.jinterface.backend.JinterfaceMessage;

public class Window extends JFrame  {
	
	private static final int defaultWidth = 400;
	private static final int defaultHeigth = 300;
	private JPanel buttonPanel;
	private JTextArea inputArea, outputArea;
	private JLabel answer;
	private JButton send, close;
	private OtpErlangListener otpErlangListener;
	private JinterfaceMessage connection = new JinterfaceMessage();
	
	public Window() {
		setTitle("Jinterface");
		setMinimumSize(new Dimension(defaultWidth, defaultHeigth));
		setLocation(300, 200);
		setVisible(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLayout(new BorderLayout());
		//setResizable(false);
		
		try {
			UIManager.setLookAndFeel("javax.swing.plaf.nimbus.NimbusLookAndFeel");			
		} catch (ClassNotFoundException | InstantiationException
				| IllegalAccessException | UnsupportedLookAndFeelException e1) {
			e1.printStackTrace();
		}
		
		if(connection.start()) {
			drawFrame();
		} else {
			JOptionPane.showMessageDialog(null, "Remote is not up", "Error", JOptionPane.ERROR_MESSAGE);
			dispose();
		}
		
		repaint();
		revalidate();
	}

	private void drawFrame() {
		otpErlangListener = new OtpErlangListener();
		
		buttonPanel = new JPanel(new FlowLayout());
		buttonPanel.setBackground(new Color(238,238,238));
		
		inputArea = new JTextArea();
		inputArea.setLineWrap(true);
		inputArea.setWrapStyleWord(true);
		JScrollPane inputScroll = new JScrollPane(inputArea);
		//add(inputScroll, BorderLayout.CENTER);
		
		answer = new JLabel("Waiting for answer...");
		//add(answer, BorderLayout.EAST);
		
		outputArea = new JTextArea("Waiting for answer...");
		outputArea.setLineWrap(true);
		outputArea.setWrapStyleWord(true);
		JScrollPane outputScroll = new JScrollPane(outputArea);
		//add(outputScroll, BorderLayout.EAST);
		
		JSplitPane split = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, inputScroll, outputScroll);
		split.setContinuousLayout(true);
		split.setOneTouchExpandable(true);
		add(split, BorderLayout.CENTER);
		
		send = new JButton("Send");
		send.addActionListener(otpErlangListener);
		close = new JButton("Close");
		close.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				connection.stop();
				dispose();
			}
		});
		buttonPanel.add(send);
		buttonPanel.add(close);
		add(buttonPanel, BorderLayout.SOUTH);
	}
	
	class OtpErlangListener implements ActionListener {
		@Override
		public void actionPerformed(ActionEvent e) {
			String message = inputArea.getText().trim();
			connection.send(message);
			//outputArea.setText(connection.getMessage().substring(1, connection.getMessage().length()-1)); outta quots
			outputArea.setText(connection.getMessage());
		}		
	}

	public static void main(String[] args) {
		new Window();
	}
}
