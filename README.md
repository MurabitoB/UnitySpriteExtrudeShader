# UnitySpriteExtrudeShader
### Unity Version  2018.4.20.f1

This is the shader using geometry shader to extrude the edge to create thickness.
You can use it in sprite renderer.

![jpeg](https://i.imgur.com/olOT0Qm.png)


## Important

The lit shader no support forward rendering, because I can't get the right result of light attention when using geometry shader.

If the sprite don't cast shadow or receive shadow, please make the inspector to Debug mode and check the option is being setted to the right option.
![jpeg](https://i.imgur.com/fW9fFtq.png)



## Credits
The sprite which I used in this demo.
https://unity-chan.com/contents/guideline/
