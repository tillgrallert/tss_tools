FasdUAS 1.101.10   ��   ��    k             l      ��  ��    � �This script tries to add a QuickTag to a list of references in Sente using GUI scripting due to the limited support for AppleScript in Sente.     � 	 	 T h i s   s c r i p t   t r i e s   t o   a d d   a   Q u i c k T a g   t o   a   l i s t   o f   r e f e r e n c e s   i n   S e n t e   u s i n g   G U I   s c r i p t i n g   d u e   t o   t h e   l i m i t e d   s u p p o r t   f o r   A p p l e S c r i p t   i n   S e n t e .   
  
 l      ��  ��    � �USE:
	- make sure to be in the main library tab
	- sort by CitationID
	- turn off your internet connection and anything that could interject anything into the GUI scripting sequence
	- turn off any text expanders
     �  � U S E : 
 	 -   m a k e   s u r e   t o   b e   i n   t h e   m a i n   l i b r a r y   t a b 
 	 -   s o r t   b y   C i t a t i o n I D 
 	 -   t u r n   o f f   y o u r   i n t e r n e t   c o n n e c t i o n   a n d   a n y t h i n g   t h a t   c o u l d   i n t e r j e c t   a n y t h i n g   i n t o   t h e   G U I   s c r i p t i n g   s e q u e n c e 
 	 -   t u r n   o f f   a n y   t e x t   e x p a n d e r s 
      l     ��������  ��  ��        l     ����  r         J            m        �    S h a w   1 9 7 5   ��  m       �    W e b e r   2 0 0 9 a��    o      ���� 0 the_ids the_IDs��  ��        l   
  ����   r    
 ! " ! m     # # � $ $  P a n d o c " o      ���� 0 the_tag  ��  ��     % & % l     ��������  ��  ��   &  ' ( ' l     �� ) *��   ) � �set dialog_tag to display dialog "Provide a tag that should be added to the reference(s)" default answer "Pandoc" with icon note buttons {"Cancel", "Continue"} default button "Continue"    * � + +r s e t   d i a l o g _ t a g   t o   d i s p l a y   d i a l o g   " P r o v i d e   a   t a g   t h a t   s h o u l d   b e   a d d e d   t o   t h e   r e f e r e n c e ( s ) "   d e f a u l t   a n s w e r   " P a n d o c "   w i t h   i c o n   n o t e   b u t t o n s   { " C a n c e l " ,   " C o n t i n u e " }   d e f a u l t   b u t t o n   " C o n t i n u e " (  , - , l     �� . /��   . 0 *set the_tag to text returned of dialog_tag    / � 0 0 T s e t   t h e _ t a g   t o   t e x t   r e t u r n e d   o f   d i a l o g _ t a g -  1 2 1 l     ��������  ��  ��   2  3 4 3 l     �� 5 6��   5 $  iterate over the citation IDs    6 � 7 7 <   i t e r a t e   o v e r   t h e   c i t a t i o n   I D s 4  8 9 8 l   � :���� : Y    � ;�� < =�� ; k    � > >  ? @ ? r     A B A l    C���� C n     D E D 4    �� F
�� 
cobj F o    ���� 0 i   E o    ���� 0 the_ids the_IDs��  ��   B o      ���� 0 this_id this_ID @  G H G O    * I J I I  $ )������
�� .miscactvnull��� ��� null��  ��   J m     ! K Kn                                                                                  SntE  alis      D889C4F5-0FC4-4893-9022-1#2    BD ����Sente 6.app                                                    ����            ����  
 cu             d   ~/:private:var:folders:84:2v35331s5t97w8g_wvsp4nv80000gq:T:AppTranslocation:D889C4F5-0FC4-4893-9022-17143224378D:d:Sente 6.app/    S e n t e   6 . a p p  J $ D 8 8 9 C 4 F 5 - 0 F C 4 - 4 8 9 3 - 9 0 2 2 - 1 7 1 4 3 2 2 4 3 7 8 D  /d/Sente 6.app  n/private/var/folders/84/2v35331s5t97w8g_wvsp4nv80000gq/T/AppTranslocation/D889C4F5-0FC4-4893-9022-17143224378D��   H  L M L I  + 0�� N��
�� .sysodelanull��� ��� nmbr N m   + , O O ?�      ��   M  P�� P Q   1 � Q R S Q O  4 � T U T l 	 8 � V���� V O   8 � W X W k   ? � Y Y  Z [ Z l  ? ?�� \ ]��   \   search for citation ID    ] � ^ ^ .   s e a r c h   f o r   c i t a t i o n   I D [  _ ` _ l  ? ?�� a b��   a   open search bar    b � c c     o p e n   s e a r c h   b a r `  d e d I  ? J�� f g
�� .prcskprsnull���     ctxt f m   ? @ h h � i i  f g �� j��
�� 
faal j m   C F��
�� eMdsKcmd��   e  k l k I  K P�� m��
�� .sysodelanull��� ��� nmbr m m   K L n n ?�      ��   l  o p o I  Q ^�� q��
�� .prcskprsnull���     ctxt q b   Q Z r s r b   Q V t u t m   Q T v v � w w  I D : " u o   T U���� 0 this_id this_ID s m   V Y x x � y y  "��   p  z { z I  _ d�� |��
�� .sysodelanull��� ��� nmbr | m   _ ` } } ?�      ��   {  ~  ~ l  e e�� � ���   � &   simulate pressing the Enter key    � � � � @   s i m u l a t e   p r e s s i n g   t h e   E n t e r   k e y   � � � I  e l�� ���
�� .prcskcodnull���     **** � m   e h���� $��   �  � � � I  m r�� ���
�� .sysodelanull��� ��� nmbr � m   m n � � ?�      ��   �  � � � l  s s�� � ���   � 3 - add a tag from the root of the QuickTag menu    � � � � Z   a d d   a   t a g   f r o m   t h e   r o o t   o f   t h e   Q u i c k T a g   m e n u �  � � � I  s ��� ���
�� .prcsclicnull��� ��� uiel � n   s � � � � 4   � ��� �
�� 
menI � o   � ����� 0 the_tag   � n   s � � � � m   � ���
�� 
menE � n   s � � � � 4   � ��� �
�� 
menI � m   � � � � � � �  A s s i g n   Q u i c k T a g � n   s � � � � m   � ���
�� 
menE � n   s � � � � 4   � ��� �
�� 
menI � m   � � � � � � �  R e f e r e n c e � n   s � � � � 4   y ��� �
�� 
menE � m   |  � � � � �  E d i t � 4   s y�� �
�� 
mbar � m   w x���� ��   �  � � � I  � ��� ���
�� .sysodelanull��� ��� nmbr � m   � � � � ?�      ��   �  � � � l  � ��� � ���   �   close search bar    � � � � "   c l o s e   s e a r c h   b a r �  ��� � I  � ��� � �
�� .prcskprsnull���     ctxt � m   � � � � � � �  f � �� ���
�� 
faal � m   � ���
�� eMdsKcmd��  ��   X 4   8 <�� �
�� 
pcap � m   : ; � � � � �  S e n t e   6��  ��   U m   4 5 � ��                                                                                  sevs  alis    X  
Fischer HD                     BD ����System Events.app                                              ����            ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p   
 F i s c h e r   H D  -System/Library/CoreServices/System Events.app   / ��   R R      ������
�� .ascrerr ****      � ****��  ��   S I  � ��� � �
�� .sysodlogaskr        TEXT � b   � � � � � m   � � � � � � � J S o m e t h i n g   w e n t   w r o n g   w i t h   C i t a t i o n I D   � o   � ����� 0 this_id this_ID � �� ���
�� 
btns � J   � � � �  ��� � m   � � � � � � �  O k a y��  ��  ��  �� 0 i   < m    ����  = l    ����� � I   �� ���
�� .corecnte****       **** � o    ���� 0 the_ids the_IDs��  ��  ��  ��  ��  ��   9  � � � l     ��������  ��  ��   �  � � � l     �� � ���   �   success message    � � � �     s u c c e s s   m e s s a g e �  ��� � l  � � ����� � I  � ��� � �
�� .sysodlogaskr        TEXT � b   � � � � � b   � � � � � m   � � � � � � � ( S u c c e s s f u l l y   a d d e d   " � o   � ����� 0 the_tag   � m   � � � � � � � 8 "   t o   a l l   s e l e c t e d   r e f e r e n c e s � �� ���
�� 
btns � J   � � � �  ��� � m   � � � � � � �  O k a y��  ��  ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k     � � �   � �   � �  8 � �  �����  ��  ��   � ���� 0 i   � (  �� #�������� K�� O�� ��� � h������ v x������� ��~ � ��} ��|�{ ��z ��y � � ��� 0 the_ids the_IDs�� 0 the_tag  
�� .corecnte****       ****
�� 
cobj�� 0 this_id this_ID
�� .miscactvnull��� ��� null
�� .sysodelanull��� ��� nmbr
�� 
pcap
�� 
faal
�� eMdsKcmd
�� .prcskprsnull���     ctxt�� $
�� .prcskcodnull���     ****
�� 
mbar
� 
menE
�~ 
menI
�} .prcsclicnull��� ��� uiel�|  �{  
�z 
btns
�y .sysodlogaskr        TEXT�� ���lvE�O�E�O �k�j kh  ��/E�O� *j 	UO�j O �� ~*��/ v�a a l O�j Oa �%a %j O�j Oa j O�j O*a k/a a /a a /a ,a a /a ,a �/j O�j Oa a a l UUW X   a !�%a "a #kvl $[OY�EOa %�%a &%a "a 'kvl $ ascr  ��ޭ