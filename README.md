# Start Here

![](https://raw.githubusercontent.com/COMP6810-Research-Project-620098373/Marketplace/media/src/assets/screenshot-001.png)

Run the **./start.sh** script file to build and launch the application. You will need bash installed on your system:

```
bash start.sh
```

## Security Settings

To view the application locally you may need to disable certain security measured shipped with modern browsers. For Chrome on Linux or MacOS, launch it with the following command:

```
google-chrome --disable-web-security --user-data-dir=/tmp
```

Once opened, navigate to `chrome://flags/#allow-insecure-localhost` and set the **"Allow invalid certificates for resources loaded from localhost."** dropdown to **Enabled**