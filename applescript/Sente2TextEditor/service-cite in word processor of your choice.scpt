FasdUAS 1.101.10   ��   ��    k             l      ��  ��    This script produces a Sente CitationID wrapped in curly braces and attaches text selected in Sente as page numbers after the @ symbol. I.e. {CitationIDofSelectedReference@SelectedText}. It then tries to copy this string into a text editor of the user's choice.      � 	 	   T h i s   s c r i p t   p r o d u c e s   a   S e n t e   C i t a t i o n I D   w r a p p e d   i n   c u r l y   b r a c e s   a n d   a t t a c h e s   t e x t   s e l e c t e d   i n   S e n t e   a s   p a g e   n u m b e r s   a f t e r   t h e   @   s y m b o l .   I . e .   { C i t a t i o n I D o f S e l e c t e d R e f e r e n c e @ S e l e c t e d T e x t } .   I t   t h e n   t r i e s   t o   c o p y   t h i s   s t r i n g   i n t o   a   t e x t   e d i t o r   o f   t h e   u s e r ' s   c h o i c e .     
  
 l     ��������  ��  ��        l      ��  ��    ( " v3: completely rewrote the script     �   D   v 3 :   c o m p l e t e l y   r e w r o t e   t h e   s c r i p t      l     ��������  ��  ��        l     ��  ��    Y S the clipboard should be reset to its original content after the end of this script     �   �   t h e   c l i p b o a r d   s h o u l d   b e   r e s e t   t o   i t s   o r i g i n a l   c o n t e n t   a f t e r   t h e   e n d   o f   t h i s   s c r i p t      l    	 ����  r     	    l     ����  I    ���� 
�� .JonsgClp****    ��� null��    �� ��
�� 
rtyp  m    ��
�� 
ctxt��  ��  ��    o      ���� (0 theclipboardbefore theClipboardBefore��  ��       !   l     �� " #��   " R L activeEditorsList will be populated in the course of the script's execution    # � $ $ �   a c t i v e E d i t o r s L i s t   w i l l   b e   p o p u l a t e d   i n   t h e   c o u r s e   o f   t h e   s c r i p t ' s   e x e c u t i o n !  % & % l  
  '���� ' r   
  ( ) ( J   
 ����   ) o      ���� &0 activeeditorslist activeEditorsList��  ��   &  * + * l     �� , -��   , v p set a list of text editors whose running status is to be checked. The order can be set to one's own preferences    - � . . �   s e t   a   l i s t   o f   t e x t   e d i t o r s   w h o s e   r u n n i n g   s t a t u s   i s   t o   b e   c h e c k e d .   T h e   o r d e r   c a n   b e   s e t   t o   o n e ' s   o w n   p r e f e r e n c e s +  / 0 / l    1���� 1 r     2 3 2 J     4 4  5 6 5 m     7 7 � 8 8  S c r i v e n e r 6  9 : 9 m     ; ; � < <  S u b l i m e   T e x t :  = > = m     ? ? � @ @  M i c r o s o f t   W o r d >  A B A m     C C � D D  T e x t E d i t B  E�� E m     F F � G G 
 n v A L T��   3 o      ���� 0 editorslist editorsList��  ��   0  H I H l     �� J K��   J #  set a list of output formats    K � L L :   s e t   a   l i s t   o f   o u t p u t   f o r m a t s I  M N M l    O P Q O r     R S R J     T T  U V U m     W W � X X 
 S e n t e V  Y�� Y m     Z Z � [ [  P a n d o c��   S o      ���� 0 formatslist formatsList P   add Zotero in the future    Q � \ \ 2   a d d   Z o t e r o   i n   t h e   f u t u r e N  ] ^ ] l     ��������  ��  ��   ^  _ ` _ l     �� a b��   a - '    Generate variable with running apps    b � c c N         G e n e r a t e   v a r i a b l e   w i t h   r u n n i n g   a p p s `  d e d l    2 f���� f O     2 g h g r   $ 1 i j i l  $ - k���� k n   $ - l m l 1   ) -��
�� 
pnam m 2   $ )��
�� 
prcs��  ��   j o      ���� "0 activeprocesses activeProcesses h m     ! n n�                                                                                  sevs  alis    X  
Fischer HD                     BD ����System Events.app                                              ����            ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p   
 F i s c h e r   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��   e  o p o l     ��������  ��  ��   p  q r q l     �� s t��   s 3 -    Generate list of running text editors        t � u u Z         G e n e r a t e   l i s t   o f   r u n n i n g   t e x t   e d i t o r s         r  v w v l  3 b x���� x X   3 b y�� z y Z   G ] { |���� { E  G L } ~ } o   G J���� "0 activeprocesses activeProcesses ~ o   J K���� 0 appname appName | k   O Y    � � � r   O T � � � o   O P���� 0 appname appName � o      ���� 0 activeeditor activeEditor �  ��� � r   U Y � � � o   U V���� 0 appname appName � n       � � �  ;   W X � o   V W���� &0 activeeditorslist activeEditorsList��  ��  ��  �� 0 appname appName z o   6 7���� 0 editorslist editorsList��  ��   w  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � � � ask user to select from running text editors if there are more then one. Otherwiese continue with the sole running text editor or abort the script    � � � �&   a s k   u s e r   t o   s e l e c t   f r o m   r u n n i n g   t e x t   e d i t o r s   i f   t h e r e   a r e   m o r e   t h e n   o n e .   O t h e r w i e s e   c o n t i n u e   w i t h   t h e   s o l e   r u n n i n g   t e x t   e d i t o r   o r   a b o r t   t h e   s c r i p t �  � � � l  c l ����� � r   c l � � � l  c h ����� � I  c h�� ���
�� .corecnte****       **** � o   c d���� &0 activeeditorslist activeEditorsList��  ��  ��   � o      ���� 0 editorcount editorCount��  ��   �  � � � l  m � ����� � Z   m � � � � � � =   m r � � � o   m p���� 0 editorcount editorCount � m   p q����  � r   u � � � � c   u } � � � l  u { ����� � n   u { � � � 4   v {�� �
�� 
cobj � m   y z����  � o   u v���� &0 activeeditorslist activeEditorsList��  ��   � m   { |��
�� 
ctxt � o      ���� 0 	targetapp 	targetApp �  � � � ?   � � � � � o   � ����� 0 editorcount editorCount � m   � �����   �  ��� � r   � � � � � c   � � � � � l  � � ����� � I  � ��� � �
�� .gtqpchltns    @   @ ns   � o   � ����� &0 activeeditorslist activeEditorsList � �� � �
�� 
appr � m   � � � � � � � ( R u n n i n g   t e x t   e d i t o r s � �� � �
�� 
prmp � m   � � � � � � � p P i c k   a   t e x t   e d i t o r   t o   s e n d   t h e   r e f e r e n c e ' s   C i t a t i o n I D   t o � �� � �
�� 
inSL � l  � � ����� � n   � � � � � 4   � ��� �
�� 
cobj � m   � �����  � o   � ����� &0 activeeditorslist activeEditorsList��  ��   � �� ���
�� 
mlsl � m   � ���
�� boovfals��  ��  ��   � m   � ���
�� 
ctxt � o      ���� 0 	targetapp 	targetApp��   � k   � � � �  � � � l  � ��� � ���   �   Handle 0 items    � � � �    H a n d l e   0   i t e m s �  � � � I  � ��� � �
�� .sysodlogaskr        TEXT � m   � � � � � � � B T h e r e   a r e   n o   r u n n i n g   t e x t   e d i t o r s � �� ���
�� 
btns � J   � � � �  ��� � m   � � � � � � �  O K��  ��   �  ��� � r   � � � � � m   � � � � � � � 
 f a l s e � o      ���� 0 	targetapp 	targetApp��  ��  ��   �  � � � l     �� � ���   � * $ ask user to select an output format    � � � � H   a s k   u s e r   t o   s e l e c t   a n   o u t p u t   f o r m a t �  � � � l  � � ����� � r   � � � � � c   � � � � � l  � � ����� � I  � ��� � �
�� .gtqpchltns    @   @ ns   � o   � ����� 0 formatslist formatsList � �� � �
�� 
appr � m   � � � � � � � 0 A v a i l a b l e   o u t p u t   f o r m a t s � �� � �
�� 
prmp � m   � � � � � � � T P i c k   a n   o u t p u t   f o r m a t   f o r   t h e   c i t a t i o n   t a g � �� � �
�� 
inSL � l  � � ����� � n   � � � � � 4   � ��� �
�� 
cobj � m   � �����  � o   � ����� 0 formatslist formatsList��  ��   � �� ���
�� 
mlsl � m   � ��
� boovfals��  ��  ��   � m   � ��~
�~ 
ctxt � o      �}�} 0 targetformat targetFormat��  ��   �  � � � l     �|�{�z�|  �{  �z   �  � � � l     �y�x�w�y  �x  �w   �  � � � l     �v � ��v   � D > retrieve the Citation ID of the selected reference from Sente    � � � � |   r e t r i e v e   t h e   C i t a t i o n   I D   o f   t h e   s e l e c t e d   r e f e r e n c e   f r o m   S e n t e �    l  ��u�t O   � k   �  r   �	 l  �	
�s�r
 I  �	�q
�q .SnccSnrsnull���     **** 1   � ��p
�p 
Sclb �o�n
�o 
Snj4 m  �m
�m SxooSotg�n  �s  �r  	 o      �l�l 0 theref theRef �k I �j�i
�j .JonspClpnull���     **** c   o  �h�h 0 theref theRef m  �g
�g 
ctxt�i  �k   m   � �n                                                                                  SntE  alis      58B76E54-B222-474C-861D-9#2    BD ����Sente 6.app                                                    ����            ����  
 cu             d   ~/:private:var:folders:84:2v35331s5t97w8g_wvsp4nv80000gq:T:AppTranslocation:58B76E54-B222-474C-861D-965D7484D65A:d:Sente 6.app/    S e n t e   6 . a p p  J $ 5 8 B 7 6 E 5 4 - B 2 2 2 - 4 7 4 C - 8 6 1 D - 9 6 5 D 7 4 8 4 D 6 5 A  /d/Sente 6.app  n/private/var/folders/84/2v35331s5t97w8g_wvsp4nv80000gq/T/AppTranslocation/58B76E54-B222-474C-861D-965D7484D65A��  �u  �t    l     �f�e�d�f  �e  �d    l     �c�c     format the citation tag     � 2   f o r m a t   t h e   c i t a t i o n   t a g    l     �b�b     Sente output    �    S e n t e   o u t p u t   l g!�a�`! Z  g"#$�_" =  %&% o  �^�^ 0 targetformat targetFormat& m  '' �(( 
 S e n t e# k  #4)) *+* r  #2,-, b  #../. b  #*010 m  #&22 �33  {1 o  &)�]�] 0 theref theRef/ m  *-44 �55  }- o      �\�\ 0 thetag theTag+ 6�[6 l 33�Z78�Z  7   Pandoc output   8 �99    P a n d o c   o u t p u t�[  $ :;: = 7><=< o  7:�Y�Y 0 targetformat targetFormat= m  :=>> �??  P a n d o c; @�X@ k  AcAA BCB l AA�WDE�W  D   replace blanks with "+"   E �FF 0   r e p l a c e   b l a n k s   w i t h   " + "C GHG r  ASIJI I  AO�VK�U�V 0 replacetext replaceTextK LML o  BE�T�T 0 theref theRefM NON m  EHPP �QQ   O R�SR m  HKSS �TT  +�S  �U  J o      �R�R 0 thetag theTagH U�QU r  TcVWV b  T_XYX b  T[Z[Z m  TW\\ �]]  [ @[ o  WZ�P�P 0 thetag theTagY m  [^^^ �__  ]W o      �O�O 0 thetag theTag�Q  �X  �_  �a  �`    `a` l     �N�M�L�N  �M  �L  a bcb l     �Kde�K  d , & copy the citatin tag to the clipboard   e �ff L   c o p y   t h e   c i t a t i n   t a g   t o   t h e   c l i p b o a r dc ghg l hqi�J�Ii I hq�Hj�G
�H .JonspClpnull���     ****j c  hmklk o  hk�F�F 0 thetag theTagl m  kl�E
�E 
ctxt�G  �J  �I  h mnm l     �D�C�B�D  �C  �B  n opo l     �Aqr�A  q  
 debugging   r �ss    d e b u g g i n gp tut l     �@vw�@  v %  display dialog (the clipboard)   w �xx >   d i s p l a y   d i a l o g   ( t h e   c l i p b o a r d )u yzy l     �?�>�=�?  �>  �=  z {|{ l     �<}~�<  } I C paste the CitationID and page number into the selected text editor   ~ � �   p a s t e   t h e   C i t a t i o n I D   a n d   p a g e   n u m b e r   i n t o   t h e   s e l e c t e d   t e x t   e d i t o r| ��� l r���;�:� Z  r����9�8� > ry��� o  ru�7�7 0 	targetapp 	targetApp� m  ux�� ��� 
 f a l s e� O  |���� k  ���� ��� I ���6�5�4
�6 .miscactvnull��� ��� null�5  �4  � ��3� O  ����� I ���2��
�2 .prcskprsnull���     ctxt� m  ���� ���  v� �1��0
�1 
faal� m  ���/
�/ eMdsKcmd�0  � m  �����                                                                                  sevs  alis    X  
Fischer HD                     BD ����System Events.app                                              ����            ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p   
 F i s c h e r   H D  -System/Library/CoreServices/System Events.app   / ��  �3  � 4  |��.�
�. 
capp� o  ���-�- 0 	targetapp 	targetApp�9  �8  �;  �:  � ��� l     �,�+�*�,  �+  �*  � ��� l     �)���)  � s m reset the clipboard to its original content, unfortunately, this action is done before the end of the script   � ��� �   r e s e t   t h e   c l i p b o a r d   t o   i t s   o r i g i n a l   c o n t e n t ,   u n f o r t u n a t e l y ,   t h i s   a c t i o n   i s   d o n e   b e f o r e   t h e   e n d   o f   t h e   s c r i p t� ��� l     �(���(  � 6 0 set the clipboard to theClipboardBefore as text   � ��� `   s e t   t h e   c l i p b o a r d   t o   t h e C l i p b o a r d B e f o r e   a s   t e x t� ��� l     �'�&�%�'  �&  �%  � ��� l     �$���$  �   helper function   � ���     h e l p e r   f u n c t i o n� ��#� i     ��� I      �"��!�" 0 replacetext replaceText� ��� o      � �  0 thetext theText� ��� o      �� "0 thesearchstring theSearchString� ��� o      �� ,0 thereplacementstring theReplacementString�  �!  � k      �� ��� r     ��� o     �� "0 thesearchstring theSearchString� n     ��� 1    �
� 
txdl� 1    �
� 
ascr� ��� r    ��� n    	��� 2    	�
� 
citm� o    �� 0 thetext theText� o      �� 0 thetextitems theTextItems� ��� r    ��� o    �� ,0 thereplacementstring theReplacementString� n     ��� 1    �
� 
txdl� 1    �
� 
ascr� ��� r    ��� c    ��� o    �� 0 thetextitems theTextItems� m    �
� 
ctxt� o      �� 0 thetext theText� ��� r    ��� m    �� ���  � n     ��� 1    �
� 
txdl� 1    �
� 
ascr� ��� L     �� o    �� 0 thetext theText�  �#       �����  � ��
� 0 replacetext replaceText
�
 .aevtoappnull  �   � ****� �	�������	 0 replacetext replaceText� ��� �  ���� 0 thetext theText� "0 thesearchstring theSearchString� ,0 thereplacementstring theReplacementString�  � �� ����� 0 thetext theText�  "0 thesearchstring theSearchString�� ,0 thereplacementstring theReplacementString�� 0 thetextitems theTextItems� ���������
�� 
ascr
�� 
txdl
�� 
citm
�� 
ctxt� !���,FO��-E�O���,FO��&E�O���,FO�� �����������
�� .aevtoappnull  �   � ****� k    ���  ��  %��  /��  M��  d��  v��  ���  ���  ���  �� �� g�� �����  ��  ��  � ���� 0 appname appName� A���������� 7 ; ? C F���� W Z�� n�������������������� ��� ��������� ��� ��� � � ���������������'24��>PS��\^������������
�� 
rtyp
�� 
ctxt
�� .JonsgClp****    ��� null�� (0 theclipboardbefore theClipboardBefore�� &0 activeeditorslist activeEditorsList�� �� 0 editorslist editorsList�� 0 formatslist formatsList
�� 
prcs
�� 
pnam�� "0 activeprocesses activeProcesses
�� 
kocl
�� 
cobj
�� .corecnte****       ****�� 0 activeeditor activeEditor�� 0 editorcount editorCount�� 0 	targetapp 	targetApp
�� 
appr
�� 
prmp
�� 
inSL
�� 
mlsl�� 
�� .gtqpchltns    @   @ ns  
�� 
btns
�� .sysodlogaskr        TEXT�� 0 targetformat targetFormat
�� 
Sclb
�� 
Snj4
�� SxooSotg
�� .SnccSnrsnull���     ****�� 0 theref theRef
�� .JonspClpnull���     ****�� 0 thetag theTag�� 0 replacetext replaceText
�� 
capp
�� .miscactvnull��� ��� null
�� 
faal
�� eMdsKcmd
�� .prcskprsnull���     ctxt���*��l E�OjvE�O������vE�O��lvE�O� *a -a ,E` UO .�[a a l kh  _ � �E` O��6FY h[OY��O�j E` O_ k  �a k/�&E` Y J_ j +�a a a a a �a k/a fa   �&E` Y a !a "a #kvl $Oa %E` O�a a &a a 'a �a k/a fa   �&E` (Oa ) *a *,a +a ,l -E` .O_ .�&j /UO_ (a 0  a 1_ .%a 2%E` 3OPY 2_ (a 4  '*_ .a 5a 6m+ 7E` 3Oa 8_ 3%a 9%E` 3Y hO_ 3�&j /O_ a : )*a ;_ / *j <O� a =a >a ?l @UUY h ascr  ��ޭ