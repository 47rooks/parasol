package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;

/**
 * This implements a flixel shader based on Tech_'s OLD TV SHADER
 * from Shadertoy. The original is at https://www.shadertoy.com/view/WdGcRh.
 */
class OldTVShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header

        //////////////////////////////////////////////////////////////////////////////////////////
        //
        //	 OLD TV SHADER
        //
        //	 by Tech_
        //
        //////////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////////

        #define COLOR_GRADING true
        #define FILM_STRIPES true
        #define FILM_TEXTURE true
        #define FILM_VIGNETTE true
        #define FILM_GRAIN true
        #define FLICKER false		// Disabled, was too strong on some devices, you may try it
        #define FILM_DIRT true
        #define DESATURATION true

        //////////////////////////////////////////////////////////////////////////////////////////

        uniform float iTime;
        uniform vec2 iResolution;
        uniform sampler2D iChannel1;
        uniform sampler2D iChannel2;
        
        float luma(vec3 color)
        {
            return dot(color, vec3(0.2126, 0.7152, 0.0722));
        }

        vec3 saturate(vec3 color, float adjustment)
        {
            vec3 intensity = vec3(luma(color));
            return mix(intensity, color, adjustment);
        }

        float flicker(in vec2 uv, float amount) 
        {
            uv *= 0.0001;
            return mix(pow(cos(uv.y * 100.2 + iTime * 80.), 0.4), 1., 1. - amount);
        }

        float filmStripes(in vec2 uv, float amount) 
        {
            float stripes;
            float mask = cos(uv.x - cos(uv.y + iTime) + sin(uv.x * 10.2) - cos(uv.x * 60. + iTime)) + sin(uv.y * 2.);
            mask += flicker(uv, 1.);
            
            if(fract(uv.x + iTime) >= 0.928 && fract(uv.x + iTime) <= 0.929) 
            {
                stripes = sin(uv.x * 4300. * sin(uv.x * 102.)) * mask;
            }
            if(fract(uv.x + fract(1. - iTime)) >= 0.98 + fract(iTime) && fract(uv.x + fract(iTime / 2. + sin(iTime / 2.))) <= 0.97 + fract(iTime + 0.2)) 
            {
                stripes = sin(uv.x * 4300. * sin(uv.x * 102.)) * mask;
            }
            if(fract(uv.x + fract(- iTime * 1. + sin(iTime / 2.))) >= 0.96 + fract(iTime) && fract(uv.x + fract(iTime / 2. + sin(iTime / 2.))) <= 0.95 + fract(iTime + 0.2)) 
            {
                stripes = sin(uv.x * 4300. * sin(uv.x * 102.)) * mask;
            }
            if(fract(uv.x + fract(- iTime * 1. + sin(iTime / 2.))) >= 0.99 + fract(iTime) && fract(uv.x + fract(iTime / 2. + sin(iTime / 2.))) <= 0.98 + fract(iTime + 0.2)) 
            {
                stripes = sin(uv.x * 4300. * sin(uv.x * 102.)) * mask;
            }
            
            stripes = 1. - stripes;
            
            return mix(1., stripes, amount);
        }

        float filmGrain(in vec2 uv, float amount) 
        {
            float grain = fract(sin(uv.x * 100. * uv.y * 524. + fract(iTime)) * 5000.);
            float w = 1.;
            return mix(w, grain, amount);
        }

        float vignette(in vec2 uv) 
        {
            uv *=  1.0 - uv.yx;
            float vig = uv.x*uv.y * 15.0;
            return clamp(pow(vig, 1.) * 1., 0., 1.);
        }

        vec3 reinhard(in vec3 color) 
        {
            return color / (1. + color);
        }

        vec3 filmDirt(in vec2 uv, float amount) 
        {
            vec2 st = uv;
            vec2 uv2 = uv;
            uv += iTime * sin(iTime);
            uv.x += sin(uv.y * 2. + iTime) * 0.3;
            uv.x *= 2.;
            uv *= 0.4;
            float mask = cos(uv.x - cos(uv.y + iTime) + sin(uv.x * 10.2) - cos(uv.x * 60. + iTime)) + sin(uv.y * 2.);
            
            float rand1 = cos(uv.x - cos(uv.y + iTime * 20.) + sin(uv.x * 10.2) - cos(uv.y * 10. + iTime * 29.)) + sin(uv.y * 2.);
            rand1 = clamp(pow(1. - rand1, 2.), 0., 1.);
            float rand2 = sin(uv.y * 80. + sin((uv.x + iTime / 60.) * 30.) + cos((uv.x + iTime / 30.) * 80.));
            rand1 += rand2 / 5.;
            rand1 = clamp(rand1, 0., 1.);
            
            float dirtHair;
            
            if(rand1 >= 0.6 && rand1 <= 0.61) 
            {
                dirtHair = 1. * abs(pow(mask, 2.)) * rand2;
            }
            
            dirtHair = 1. - dirtHair;
            dirtHair /= rand1;
            
            st.x *= iResolution.x / iResolution.y;
            st.x += sin(st.y * 2. + iTime) * 0.1;
            st.y += sin(st.x * 2. + iTime) * 0.1;
            st += sin(iTime + 0.5 + cos(iTime * 2.)) * 10. + sin(-iTime);
            st.y += sin(iTime + 0.1 + cos(iTime * 20.)) * 10. + sin(-iTime);
            st.x += sin(iTime * 20. + sin(iTime * 80.)) + cos(iTime * 20.);
            float noise = luma(flixel_texture2D(iChannel1, st).rgb);
            float dirtDots;
            dirtDots = 1. - smoothstep(0.7, 0.93, noise);
            dirtDots += flicker(st, 1.);
            float dirtDotsMask = sin((uv2.x + iTime) * 20. + cos((uv2.y + iTime) * 5. + cos(uv2.x + iTime * 2.)));
            dirtDotsMask = clamp(dirtDotsMask, 0., 1.);
            dirtDotsMask += sin(uv2.y * 10. + cos(uv2.x * 10.) + uv.x);
            dirtDotsMask = clamp(dirtDotsMask, 0., 1.);
            dirtDots = clamp(dirtDots, 0., 1.);
            dirtDots /= dirtDotsMask;
            dirtDots /= rand1;
            
            float result = clamp(dirtDots * dirtHair, 0., 1.);
            
            return vec3(mix(1., result, amount));
        }

        float filmNoise(in vec2 uv) 
        {
            vec2 uv2 = uv;
            uv *= 0.8;
            vec2 st = uv;
            uv.x *= iResolution.x / iResolution.y;
            uv *= 0.6 + cos(iTime) / 5.;
            uv.y += sin(iTime * 22.);
            uv.x -= cos(iTime * 22.);
            st *= 0.5 + sin(iTime) / 5.;
            st.y -= sin(iTime * 23.);
            st.x += cos(iTime * 22.);
            
            float tex1 = luma(flixel_texture2D(iChannel2, uv.yx).rgb);
            float tex2 = luma(flixel_texture2D(iChannel2, st).rgb);
            float finalTex = tex2 * tex1;
            float texMask = 1. - pow(distance(uv2, vec2(0.5)), 2.2);
            finalTex = clamp(1. - (finalTex + texMask), 0., 1.);
            float w = 1.;
            
            return finalTex;
        }

        void main()
        {
            // Normalized pixel coordinates (from 0 to 1)
            vec2 uv = openfl_TextureCoordv;

            
            
            vec3 col = flixel_texture2D(bitmap, uv).rgb;
            
            if(COLOR_GRADING) 
            {
                col *= luma(col);
                col *= 1.9;
                col = col / 1.8 + 0.12;
            }

            if(FILM_STRIPES) 
            {
                col += 1. - filmStripes(uv, 0.07);
                col += 1. - filmStripes(uv + uv, 0.05);
            }

            if(FILM_TEXTURE) 
            {
                col -= filmNoise(uv) / 4.;
            }

            if(FILM_VIGNETTE) 
            {
                col *= vignette(uv) * 1.1;
            }

            if(FILM_GRAIN) 
            {
                col *= filmGrain(uv, 0.16);
            }

            if(FLICKER) 
            {
                col *= flicker(uv, 0.1);
            }

            if(FILM_DIRT) 
            {
                col *= filmDirt(uv / 1.3, 0.15);
            }

            if(DESATURATION) 
            {
                col = saturate(col, 0.);
            }

            if(COLOR_GRADING) 
            {
                col.r *= 1.01;
                col.g *= 1.02;
            }
            
            // Output to screen
            gl_FragColor = vec4(col, 1.);
        }
    ")
	public function new(width:Float, height:Float)
	{
		super();

		this.iTime.value = [0.0];
		this.iResolution.value = [width, height];

		// Read the pebble texture
		var pebbles = new FlxSprite(0, 0);
		pebbles.loadGraphic(AssetPaths.pebbles__png);
		this.iChannel1.input = pebbles.pixels;

		// Read the noise texture
		var noise = new FlxSprite(0, 0);
		noise.loadGraphic(AssetPaths.abstract3__jpg);
		this.iChannel2.input = noise.pixels;
	}

	public function update(iTime:Float):Void
	{
		this.iTime.value = [iTime];
	}
}
