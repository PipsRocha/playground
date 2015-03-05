package controls;

import android.app.Activity;
import android.content.Context;

import com.w2.api.engine.components.commands.BodyWheels;
import com.w2.api.engine.components.commands.EyeRing;
import com.w2.api.engine.components.commands.HeadPosition;
import com.w2.api.engine.components.commands.LightMono;
import com.w2.api.engine.components.commands.LightRGB;
import com.w2.api.engine.operators.RobotCommandSet;
import com.w2.api.engine.robots.Robot;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.util.Hashtable;

import play_i.playground.R;

/**
 * Created by ilitvinenko on 3/4/15.
 * DataArt
 */
public class RobotControl implements ControlInterfaces.IRobotManagement,
                                     ControlInterfaces.ILightsControl,
                                     ControlInterfaces.IEyeControl,
                                     ControlInterfaces.IWheelControl {

  private Robot activeRobot;
  private Hashtable<Integer, JSONObject> cachedAnimations = new Hashtable<>();
  private WeakReference<Activity> holder;

  public Robot getActiveRobot() {
    return activeRobot;
  }

  public void setActiveRobot(Robot activeRobot) {
    this.activeRobot = activeRobot;
  }

  private boolean isActiveRobotAvailable(){
    return (activeRobot != null && activeRobot.isConnected());
  }

  public void setHolder(Activity activity){
    holder = new WeakReference<Activity>(activity);
  }

  private JSONObject loadAnimationWithId(int resourceId){
    JSONObject animation = cachedAnimations.get(resourceId);
    if (animation == null) {
      try {
        String jsonString = loadJsonStringFromFile(holder.get(), resourceId);
        animation = new JSONObject(jsonString);
        cachedAnimations.put(resourceId, animation);
      } catch (IOException e) {
        e.printStackTrace();
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
    return animation;
  }

  private String loadJsonStringFromFile(Context context, int resourceId) throws IOException {
    if (context == null) { return "";  }

    InputStream file = context.getResources().openRawResource(resourceId);
    byte[] data = new byte[file.available()];
    file.read(data);
    file.close();
    return new String(data);
  }

  @Override
  public void setLeftEarColor(double red, double green, double blue) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandLeftEarLight(new LightRGB(red, green, blue));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setRightEarColor(double red, double green, double blue) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandRightEarLight(new LightRGB(red, green, blue));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setChestColor(double red, double green, double blue) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandChestLight(new LightRGB(red, green, blue));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setMainButtonBrightness(double brightness) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandMainButtonLight(new LightMono(brightness));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setTailBrightness(double brightness) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandTailLight(new LightMono(brightness));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setEyesLightAndBrightness(boolean[] states, double brightness) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandEyeRing(new EyeRing(brightness, states));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void startEyeBlinkAnimation() {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandEyeRing(new EyeRing(EyeRing.EYEANIM_FULL_BLINK_FILE));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void setWheelAttributes(double linear, double angle) {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandBodyWheels(new BodyWheels(linear, angle));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void playWiggleAnimation() {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.fromJson(loadAnimationWithId(R.raw.wiggle));
    activeRobot.sendCommandSet(commandSet);
  }

  @Override
  public void playNodAnimation() {
    if (!isActiveRobotAvailable()) return;

    RobotCommandSet commandSet = RobotCommandSet.emptySet();
    commandSet.addCommandHeadPositionTilt(new HeadPosition(-20));
    commandSet.addCommandHeadPositionTilt(new HeadPosition(7.5));
    commandSet.addCommandHeadPositionTilt(new HeadPosition(-20));
    commandSet.addCommandHeadPositionTilt(new HeadPosition(7.5));
    activeRobot.sendCommandSet(commandSet);
  }
}
